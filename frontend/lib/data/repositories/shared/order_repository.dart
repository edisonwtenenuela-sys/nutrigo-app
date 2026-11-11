import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

import 'package:emprendedor/core/constants/app_constants.dart';
import 'package:emprendedor/data/models/shared/order_business_summary.dart';
import 'package:emprendedor/data/models/shared/order_model.dart';

final Logger logger = Logger('OrderRepository');

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection(AppConstants.ordersCollection);

  Stream<List<OrderModel>> getOrders(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapOrderDocs);
  }

  Stream<List<OrderModel>> getOrdersForBusiness(String businessUserId) {
    return _ordersCollection
        .where('businessUserId', isEqualTo: businessUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapOrderDocs);
  }

  Future<OrderModel?> getOrderById(String orderId, String userId) async {
    final doc = await _ordersCollection.doc(orderId).get();
    if (!_isAuthorizedDoc(doc, key: 'userId', expectedValue: userId)) {
      return null;
    }
    return OrderModel.fromFirestore(doc);
  }

  Future<OrderModel?> waitForClientOrderNumber({
    required String orderId,
    required String userId,
    Duration timeout = const Duration(seconds: 4),
  }) async {
    try {
      return await _ordersCollection
          .doc(orderId)
          .snapshots()
          .map((doc) {
            if (!_isAuthorizedDoc(doc, key: 'userId', expectedValue: userId)) {
              return null;
            }
            return OrderModel.fromFirestore(doc);
          })
          .firstWhere((order) => order?.hasOrderNumber == true)
          .timeout(timeout);
    } catch (_) {
      return getOrderById(orderId, userId);
    }
  }

  Future<OrderModel?> getOrderByIdForBusiness(
    String orderId,
    String businessUserId,
  ) async {
    final doc = await _ordersCollection.doc(orderId).get();
    if (!_isAuthorizedDoc(
      doc,
      key: 'businessUserId',
      expectedValue: businessUserId,
    )) {
      return null;
    }
    return OrderModel.fromFirestore(doc);
  }

  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus newStatus,
    String userId,
  ) async {
    final docRef = _ordersCollection.doc(orderId);
    final doc = await docRef.get(const GetOptions(source: Source.server));
    _ensureAuthorized(
      doc,
      key: 'userId',
      expectedValue: userId,
      unauthorizedMessage: 'Pedido no encontrado o usuario no autorizado.',
    );

    final currentStatus = stringToOrderStatus(
      doc.data()?['status']?.toString(),
    );
    _validateStatusTransition(currentStatus, newStatus);
    await _updateOrderStatusData(docRef, newStatus);
  }

  Future<void> updateOrderStatusForBusiness(
    String orderId,
    OrderStatus newStatus,
    String businessUserId,
  ) async {
    final docRef = _ordersCollection.doc(orderId);
    final doc = await docRef.get(const GetOptions(source: Source.server));
    _ensureAuthorized(
      doc,
      key: 'businessUserId',
      expectedValue: businessUserId,
      unauthorizedMessage: 'Pedido no autorizado para este negocio.',
    );

    final orderData = doc.data()!;
    final currentStatus = stringToOrderStatus(orderData['status']?.toString());
    _validateStatusTransition(currentStatus, newStatus);

    await _updateOrderStatusData(docRef, newStatus);
  }

  Future<void> updatePaymentStatusForBusiness(
    String orderId,
    PaymentStatus newStatus,
    String businessUserId,
  ) async {
    final docRef = _ordersCollection.doc(orderId);
    final doc = await docRef.get(const GetOptions(source: Source.server));
    _ensureAuthorized(
      doc,
      key: 'businessUserId',
      expectedValue: businessUserId,
      unauthorizedMessage:
          'No autorizado para actualizar el pago de este pedido.',
    );

    await docRef.update({
      'paymentStatus': paymentStatusToString(newStatus),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePaymentStatusForClient(
    String orderId,
    PaymentStatus newStatus,
    String userId, {
    String? paymentIntentId,
  }) async {
    final docRef = _ordersCollection.doc(orderId);
    final doc = await docRef.get(const GetOptions(source: Source.server));
    _ensureAuthorized(
      doc,
      key: 'userId',
      expectedValue: userId,
      unauthorizedMessage:
          'No autorizado para actualizar el pago de este pedido.',
    );

    final data = <String, dynamic>{
      'paymentStatus': paymentStatusToString(newStatus),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (paymentIntentId != null && paymentIntentId.trim().isNotEmpty) {
      data['paymentIntentId'] = paymentIntentId;
    }

    await docRef.update(data);
  }

  Future<DocumentReference> addOrder(OrderModel order) async {
    try {
      final newOrderRef = _ordersCollection.doc();
      final data = order.toFirestore();
      data['paymentMethod'] = order.paymentMethod;
      data['paymentStatus'] = paymentStatusToString(order.paymentStatus);
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      if (order.paymentIntentId != null &&
          order.paymentIntentId!.trim().isNotEmpty) {
        data['paymentIntentId'] = order.paymentIntentId;
      }

      await newOrderRef.set(data);
      return newOrderRef;
    } catch (e, stackTrace) {
      logger.severe(
        'Error adding order for user: ${order.userId}',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<OrderBusinessSummary> getBusinessSummaryForOrder(
    String businessUserId,
  ) async {
    try {
      final doc = await _firestore
          .collection('business_profiles')
          .doc(businessUserId)
          .get();

      if (doc.exists && doc.data() != null) {
        return _businessSummaryFromData(doc.data()!);
      }

      final snapshot = await _firestore
          .collection('business_profiles')
          .where('userId', isEqualTo: businessUserId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return OrderBusinessSummary.fallback;

      return _businessSummaryFromData(snapshot.docs.first.data());
    } catch (_) {
      return OrderBusinessSummary.fallback;
    }
  }

  Stream<OrderBusinessSummary> watchBusinessSummaryForOrder(
    String businessUserId,
  ) {
    return _firestore
        .collection('business_profiles')
        .doc(businessUserId)
        .snapshots()
        .map((doc) {
          final data = doc.data();
          if (!doc.exists || data == null) return OrderBusinessSummary.fallback;
          return _businessSummaryFromData(data);
        });
  }

  Stream<Map<String, OrderBusinessSummary>> watchBusinessSummariesForOrders(
    List<String> businessUserIds,
  ) {
    final ids = businessUserIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (ids.isEmpty) {
      return Stream.value(const <String, OrderBusinessSummary>{});
    }

    return _firestore.collection('business_profiles').snapshots().map((
      snapshot,
    ) {
      final summaries = <String, OrderBusinessSummary>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final userId = (data['userId']?.toString().trim().isNotEmpty == true)
            ? data['userId'].toString().trim()
            : doc.id.trim();

        if (!ids.contains(userId)) continue;
        summaries[userId] = _businessSummaryFromData(data);
      }

      return summaries;
    });
  }

  OrderBusinessSummary _businessSummaryFromData(Map<String, dynamic> data) {
    return OrderBusinessSummary(
      name: data['name']?.toString() ?? 'Emprendedor',
      imageUrl: data['profileImageUrl']?.toString(),
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      totalReviews: (data['totalReviews'] as num?)?.toInt() ?? 0,
      openingHours: data['openingHours']?.toString(),
      description: data['description']?.toString(),
    );
  }

  Future<void> deleteOrder(String orderId, String userId) async {
    final docRef = _ordersCollection.doc(orderId);
    final orderDoc = await docRef.get();
    _ensureAuthorized(
      orderDoc,
      key: 'userId',
      expectedValue: userId,
      unauthorizedMessage: 'No autorizado para eliminar este pedido.',
    );
    await docRef.delete();
  }

  List<OrderModel> _mapOrderDocs(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
  }

  bool _isAuthorizedDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String key,
    required String expectedValue,
  }) {
    return doc.exists && doc.data()?[key] == expectedValue;
  }

  void _ensureAuthorized(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String key,
    required String expectedValue,
    required String unauthorizedMessage,
  }) {
    if (!_isAuthorizedDoc(doc, key: key, expectedValue: expectedValue)) {
      throw Exception(unauthorizedMessage);
    }
  }

  Future<void> _updateOrderStatusData(
    DocumentReference docRef,
    OrderStatus newStatus,
  ) async {
    final updateData = <String, dynamic>{
      'status': orderStatusToString(newStatus),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (newStatus == OrderStatus.delivered) {
      updateData['deliveredAt'] = FieldValue.serverTimestamp();
      updateData['paymentStatus'] = paymentStatusToString(PaymentStatus.paid);
    }

    await docRef.update(updateData);
  }

  void _validateStatusTransition(OrderStatus current, OrderStatus next) {
    final validTransitions = <OrderStatus, List<OrderStatus>>{
      OrderStatus.pending: [OrderStatus.confirmed, OrderStatus.cancelled],
      OrderStatus.confirmed: [OrderStatus.preparing, OrderStatus.cancelled],
      OrderStatus.preparing: [OrderStatus.shipped, OrderStatus.cancelled],
      OrderStatus.shipped: [OrderStatus.delivered],
      OrderStatus.delivered: [],
      OrderStatus.cancelled: [],
    };

    final allowedTransitions = validTransitions[current] ?? [];
    if (!allowedTransitions.contains(next)) {
      throw Exception(
        'Transición inválida: ${getOrderStatusDisplayString(current)} -> ${getOrderStatusDisplayString(next)}',
      );
    }
  }
}
