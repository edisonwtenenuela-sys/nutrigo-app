import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

import 'package:emprendedor/data/models/admin/nutritionist_verification_request_model.dart';

class NutritionistVerificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _log = Logger('NutritionistVerificationRepository');

  static const String _collection = 'nutritionist_verifications';

  Stream<List<NutritionistVerificationRequestModel>> getPendingRequests() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      final requests = snapshot.docs
          .map(
            (doc) => NutritionistVerificationRequestModel.fromMap(
              doc.id,
              doc.data(),
            ),
          )
          .where((request) {
            final status = request.status.trim().toLowerCase();
            // Aceptar 'pending' y 'pendiente' por compatibilidad con datos existentes
            return status.isEmpty ||
                status == 'pending' ||
                status == 'pendiente';
          })
          .toList();

      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests;
    });
  }

  Stream<List<NutritionistVerificationRequestModel>> getApprovedRequests() {
    return getRequestsByStatus('approved');
  }

  Stream<List<NutritionistVerificationRequestModel>> getRejectedRequests() {
    return getRequestsByStatus('rejected');
  }

  Stream<List<NutritionistVerificationRequestModel>> getRequestsByStatus(
    String status,
  ) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
          final requests = snapshot.docs.map((doc) {
            return NutritionistVerificationRequestModel.fromMap(
              doc.id,
              doc.data(),
            );
          }).toList();

          requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return requests;
        });
  }

  Future<void> verifyRequestCanBeReviewed({
    required String requestId,
    required String userId,
  }) async {
    final requestRef = _firestore.collection(_collection).doc(requestId);
    final userRef = _firestore.collection('users').doc(userId);

    await _verifyPendingRequestAndUser(
      requestRef: requestRef,
      userRef: userRef,
    );
  }

  Future<void> approveRequest({
    required String requestId,
    required String userId,
  }) async {
    try {
      final requestRef = _firestore.collection(_collection).doc(requestId);
      final userRef = _firestore.collection('users').doc(userId);
      final nutritionistRef = _firestore
          .collection('nutritionists')
          .doc(userId);

      await _verifyPendingRequestAndUser(
        requestRef: requestRef,
        userRef: userRef,
      );

      final batch = _firestore.batch();

      batch.update(requestRef, {
        'status': 'approved',
        'message': '',
        'reviewedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.update(userRef, {
        'role': 'nutricionista',
        'isVerified': true,
        'verificationStatus': 'approved',
        'verificationMessage': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.set(nutritionistRef, {
        'role': 'nutricionista',
        'isVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit().timeout(const Duration(seconds: 12));
      _log.info(
        'Solicitud nutricionista $requestId aprobada para usuario $userId',
      );
    } catch (e, st) {
      _log.severe('Error aprobando solicitud nutricionista $requestId', e, st);
      rethrow;
    }
  }

  Future<void> rejectRequest({
    required String requestId,
    required String userId,
    required String reason,
  }) async {
    try {
      final message = reason.trim();

      final requestRef = _firestore.collection(_collection).doc(requestId);
      final userRef = _firestore.collection('users').doc(userId);
      final nutritionistRef = _firestore
          .collection('nutritionists')
          .doc(userId);

      await _verifyPendingRequestAndUser(
        requestRef: requestRef,
        userRef: userRef,
      );

      final batch = _firestore.batch();

      batch.update(requestRef, {
        'status': 'rejected',
        'message': message,
        'reviewedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.update(userRef, {
        'role': 'pending_nutritionist',
        'isVerified': false,
        'verificationStatus': 'rejected',
        'verificationMessage': message,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.set(nutritionistRef, {
        'isVerified': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit().timeout(const Duration(seconds: 12));
      _log.info(
        'Solicitud nutricionista $requestId rechazada para usuario $userId',
      );
    } catch (e, st) {
      _log.severe('Error rechazando solicitud nutricionista $requestId', e, st);
      rethrow;
    }
  }

  Future<void> _verifyPendingRequestAndUser({
    required DocumentReference<Map<String, dynamic>> requestRef,
    required DocumentReference<Map<String, dynamic>> userRef,
  }) async {
    final requestDoc = await requestRef
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 10));
    final userDoc = await userRef
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 10));

    if (!requestDoc.exists) {
      throw Exception('La solicitud ya no está disponible.');
    }
    if (!userDoc.exists) {
      throw Exception('El usuario ya no está disponible.');
    }

    final status = requestDoc.data()?['status']?.toString().toLowerCase();
    if (status != null &&
        status.isNotEmpty &&
        status != 'pending' &&
        status != 'pendiente') {
      throw Exception('La solicitud ya fue revisada.');
    }
  }
}
