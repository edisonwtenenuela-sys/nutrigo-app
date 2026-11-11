import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emprendedor/data/models/shared/user_model.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  shipped,
  delivered,
  cancelled,
}

enum PaymentStatus { pending, paid, failed, refunded }

String orderStatusToString(OrderStatus status) => status.name;

OrderStatus stringToOrderStatus(String? statusStr) {
  switch (statusStr?.toLowerCase()) {
    case 'confirmed':
      return OrderStatus.confirmed;
    case 'preparing':
      return OrderStatus.preparing;
    case 'shipped':
      return OrderStatus.shipped;
    case 'delivered':
      return OrderStatus.delivered;
    case 'cancelled':
      return OrderStatus.cancelled;
    case 'pending':
    default:
      return OrderStatus.pending;
  }
}

String getOrderStatusDisplayString(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return 'Pendiente';
    case OrderStatus.confirmed:
      return 'Confirmado';
    case OrderStatus.preparing:
      return 'En preparación';
    case OrderStatus.shipped:
      return 'En camino';
    case OrderStatus.delivered:
      return 'Entregado';
    case OrderStatus.cancelled:
      return 'Cancelado';
  }
}

String paymentStatusToString(PaymentStatus status) => status.name;

PaymentStatus stringToPaymentStatus(String? statusStr) {
  switch (statusStr?.toLowerCase()) {
    case 'paid':
      return PaymentStatus.paid;
    case 'failed':
      return PaymentStatus.failed;
    case 'refunded':
      return PaymentStatus.refunded;
    case 'pending':
    default:
      return PaymentStatus.pending;
  }
}

String getPaymentStatusDisplayString(PaymentStatus status) {
  switch (status) {
    case PaymentStatus.pending:
      return 'Pendiente';
    case PaymentStatus.paid:
      return 'Pagado';
    case PaymentStatus.failed:
      return 'Fallido';
    case PaymentStatus.refunded:
      return 'Reembolsado';
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double priceAtPurchase;
  final String? imageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.priceAtPurchase,
    this.imageUrl,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId']?.toString() ?? '',
      productName: map['productName']?.toString() ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      priceAtPurchase: (map['priceAtPurchase'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'priceAtPurchase': priceAtPurchase,
    };

    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      data['imageUrl'] = imageUrl;
    }

    return data;
  }
}

class OrderModel {
  final String? id;
  final int? orderNumber;

  final String userId;
  final String businessUserId;

  final List<OrderItem> items;

  /// Total final pagado o pendiente de pago.
  final double totalPrice;

  /// Total antes del descuento.
  final double originalTotal;

  /// Valor descontado por cupón.
  final double discountAmount;

  final double finalTotal;

  final OrderStatus status;

  final String paymentMethod;
  final PaymentStatus paymentStatus;
  final String? paymentIntentId;

  final String shippingAddress;
  final double? latitude;
  final double? longitude;

  final UserModel customerInfo;

  final Timestamp createdAt;
  final Timestamp? updatedAt;
  final Timestamp? deliveredAt;

  final String? couponId;
  final String? couponCode;
  final String? promotionId;

  final bool? isFeaturedProduct;

  OrderModel({
    this.id,
    this.orderNumber,
    required this.userId,
    required this.businessUserId,
    required this.items,
    required this.totalPrice,
    double? originalTotal,
    this.discountAmount = 0.0,
    double? finalTotal,
    this.status = OrderStatus.pending,
    required this.paymentMethod,
    this.paymentStatus = PaymentStatus.pending,
    this.paymentIntentId,
    required this.shippingAddress,
    this.latitude,
    this.longitude,
    required this.customerInfo,
    required this.createdAt,
    this.updatedAt,
    this.deliveredAt,
    this.couponId,
    this.couponCode,
    this.promotionId,
    this.isFeaturedProduct,
  }) : originalTotal = originalTotal ?? totalPrice,
       finalTotal = finalTotal ?? totalPrice;

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final rawItems = data['items'] as List<dynamic>? ?? [];

    final parsedTotal = (data['totalPrice'] as num?)?.toDouble() ?? 0.0;

    return OrderModel(
      id: doc.id,
      orderNumber: (data['orderNumber'] as num?)?.toInt(),
      userId: data['userId']?.toString() ?? '',
      businessUserId: data['businessUserId']?.toString() ?? '',
      items: rawItems
          .whereType<Map>()
          .map(
            (itemMap) => OrderItem.fromMap(Map<String, dynamic>.from(itemMap)),
          )
          .toList(),
      totalPrice: parsedTotal,
      originalTotal: (data['originalTotal'] as num?)?.toDouble() ?? parsedTotal,
      discountAmount: (data['discountAmount'] as num?)?.toDouble() ?? 0.0,
      finalTotal: (data['finalTotal'] as num?)?.toDouble() ?? parsedTotal,
      status: stringToOrderStatus(data['status']?.toString()),
      paymentMethod: data['paymentMethod']?.toString() ?? 'No especificado',
      paymentStatus: stringToPaymentStatus(data['paymentStatus']?.toString()),
      paymentIntentId: data['paymentIntentId']?.toString(),
      shippingAddress: data['shippingAddress']?.toString() ?? 'N/A',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      customerInfo: UserModel.fromEmbeddedData(
        Map<String, dynamic>.from(
          (data['customerInfo'] as Map?) ?? <String, dynamic>{},
        ),
      ),
      createdAt: data['createdAt'] is Timestamp
          ? data['createdAt'] as Timestamp
          : Timestamp.now(),
      updatedAt: data['updatedAt'] is Timestamp
          ? data['updatedAt'] as Timestamp
          : null,
      deliveredAt: data['deliveredAt'] is Timestamp
          ? data['deliveredAt'] as Timestamp
          : null,
      couponId: data['couponId']?.toString(),
      couponCode: data['couponCode']?.toString(),
      promotionId: data['promotionId']?.toString(),
      isFeaturedProduct: data['isFeaturedProduct'] as bool?,
    );
  }

  Map<String, dynamic> toFirestore() {
    final data = <String, dynamic>{
      if (orderNumber != null) 'orderNumber': orderNumber,
      'userId': userId,
      'businessUserId': businessUserId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalPrice': totalPrice,
      'originalTotal': originalTotal,
      'discountAmount': discountAmount,
      'finalTotal': finalTotal,
      'status': orderStatusToString(status),
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatusToString(paymentStatus),
      'shippingAddress': shippingAddress,
      'customerInfo': customerInfo.toEmbeddedData(),
      'createdAt': createdAt,
    };

    if (paymentIntentId != null && paymentIntentId!.trim().isNotEmpty) {
      data['paymentIntentId'] = paymentIntentId;
    }

    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;
    if (updatedAt != null) data['updatedAt'] = updatedAt;
    if (deliveredAt != null) data['deliveredAt'] = deliveredAt;

    if (couponId != null && couponId!.trim().isNotEmpty) {
      data['couponId'] = couponId;
    }

    if (couponCode != null && couponCode!.trim().isNotEmpty) {
      data['couponCode'] = couponCode;
    }

    if (promotionId != null && promotionId!.trim().isNotEmpty) {
      data['promotionId'] = promotionId;
    }

    if (isFeaturedProduct != null) {
      data['isFeaturedProduct'] = isFeaturedProduct;
    }

    return data;
  }

  OrderModel copyWith({
    String? id,
    int? orderNumber,
    String? userId,
    String? businessUserId,
    List<OrderItem>? items,
    double? totalPrice,
    double? originalTotal,
    double? discountAmount,
    double? finalTotal,
    OrderStatus? status,
    String? paymentMethod,
    PaymentStatus? paymentStatus,
    String? paymentIntentId,
    String? shippingAddress,
    double? latitude,
    double? longitude,
    UserModel? customerInfo,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Timestamp? deliveredAt,
    String? couponId,
    String? couponCode,
    String? promotionId,
    bool? isFeaturedProduct,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      businessUserId: businessUserId ?? this.businessUserId,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      originalTotal: originalTotal ?? this.originalTotal,
      discountAmount: discountAmount ?? this.discountAmount,
      finalTotal: finalTotal ?? this.finalTotal,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      customerInfo: customerInfo ?? this.customerInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      couponId: couponId ?? this.couponId,
      couponCode: couponCode ?? this.couponCode,
      promotionId: promotionId ?? this.promotionId,
      isFeaturedProduct: isFeaturedProduct ?? this.isFeaturedProduct,
    );
  }

  String get formattedOrderNumber {
    if (orderNumber == null) return '#----';
    return '#${orderNumber.toString().padLeft(4, '0')}';
  }

  bool get hasOrderNumber => orderNumber != null;

  double get calculatedTotal {
    return items.fold(
      0.0,
      (accumulator, item) =>
          accumulator + (item.quantity * item.priceAtPurchase),
    );
  }

  bool get hasDiscount => discountAmount > 0;

  bool get isPending => status == OrderStatus.pending;
  bool get isConfirmed => status == OrderStatus.confirmed;
  bool get isPreparing => status == OrderStatus.preparing;
  bool get isShipped => status == OrderStatus.shipped;
  bool get isDelivered => status == OrderStatus.delivered;
  bool get isCancelled => status == OrderStatus.cancelled;

  bool get canBeCancelled {
    return status != OrderStatus.delivered && status != OrderStatus.cancelled;
  }

  bool get canChangeStatus {
    return status != OrderStatus.delivered && status != OrderStatus.cancelled;
  }

  OrderStatus? get nextStatus {
    switch (status) {
      case OrderStatus.pending:
        return OrderStatus.confirmed;
      case OrderStatus.confirmed:
        return OrderStatus.preparing;
      case OrderStatus.preparing:
        return OrderStatus.shipped;
      case OrderStatus.shipped:
        return OrderStatus.delivered;
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return null;
    }
  }

  String get nextStatusText {
    final next = nextStatus;
    if (next == null) return 'Finalizado';
    return getOrderStatusDisplayString(next);
  }

  String get estimatedDeliveryText {
    switch (status) {
      case OrderStatus.pending:
        return '30 - 40 min';
      case OrderStatus.confirmed:
        return '25 - 35 min';
      case OrderStatus.preparing:
        return '20 - 30 min';
      case OrderStatus.shipped:
        return '5 - 15 min';
      case OrderStatus.delivered:
        return 'Pedido entregado';
      case OrderStatus.cancelled:
        return 'Pedido cancelado';
    }
  }

  String get statusDescription {
    switch (status) {
      case OrderStatus.pending:
        return 'Tu pedido fue recibido y está pendiente de confirmación.';
      case OrderStatus.confirmed:
        return 'El emprendimiento confirmó tu pedido.';
      case OrderStatus.preparing:
        return 'Tu pedido en NutriGo está siendo preparado.';
      case OrderStatus.shipped:
        return 'Tu pedido ya salió y va camino a tu ubicación.';
      case OrderStatus.delivered:
        return 'Tu pedido fue entregado exitosamente.';
      case OrderStatus.cancelled:
        return 'Este pedido fue cancelado.';
    }
  }

  double get progressPercentage {
    switch (status) {
      case OrderStatus.pending:
        return 0.15;
      case OrderStatus.confirmed:
        return 0.30;
      case OrderStatus.preparing:
        return 0.55;
      case OrderStatus.shipped:
        return 0.85;
      case OrderStatus.delivered:
        return 1.0;
      case OrderStatus.cancelled:
        return 0.0;
    }
  }
}








