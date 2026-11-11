import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

import 'package:emprendedor/data/models/entrepreneur/payments/payment_method_model.dart';

class PaymentMethodRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger('PaymentMethodRepository');

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('payment_methods');
  }

  Stream<List<PaymentMethodModel>> getPaymentMethods(String userId) {
    return _collection(
      userId,
    ).orderBy('createdAt', descending: false).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PaymentMethodModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> addPaymentMethod(
    String userId,
    PaymentMethodModel paymentMethod,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 10));

      final data = paymentMethod.copyWith(userId: userId).toFirestore();

      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _collection(userId).add(data).timeout(const Duration(seconds: 12));
    } catch (e, st) {
      _logger.severe('Error añadiendo método de pago', e, st);
      rethrow;
    }
  }

  Future<void> updatePaymentMethod(
    String userId,
    PaymentMethodModel paymentMethod,
  ) async {
    if (paymentMethod.id == null || paymentMethod.id!.trim().isEmpty) {
      throw Exception('ID requerido para actualizar');
    }

    try {
      final docRef = _collection(userId).doc(paymentMethod.id);
      final doc = await docRef
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 10));

      if (!doc.exists) {
        throw Exception('Método de pago no encontrado.');
      }

      final data = paymentMethod.copyWith(userId: userId).toFirestore();

      data.remove('createdAt');
      data['updatedAt'] = FieldValue.serverTimestamp();

      await docRef
          .set(data, SetOptions(merge: true))
          .timeout(const Duration(seconds: 12));
    } catch (e, st) {
      _logger.severe('Error actualizando método de pago', e, st);
      rethrow;
    }
  }

  Future<void> deletePaymentMethod(String userId, String docId) async {
    try {
      final docRef = _collection(userId).doc(docId);
      final doc = await docRef
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 10));

      if (!doc.exists) {
        throw Exception('Método de pago no encontrado.');
      }

      await docRef.delete().timeout(const Duration(seconds: 12));
    } catch (e, st) {
      _logger.severe('Error eliminando método de pago', e, st);
      rethrow;
    }
  }
}
