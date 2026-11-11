import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logging/logging.dart';

import 'package:emprendedor/data/models/client/client_profile_model.dart';

class ClientProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Logger _logger = Logger('ClientProfileRepository');

  static const String _collection = 'clients';

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection(_collection);

  Future<void> createClientProfile(ClientProfileModel profile) async {
    try {
      await _ref
          .doc(profile.userId)
          .set(profile.toMap(), SetOptions(merge: true));
      await _syncUserProfile(profile);
    } catch (e, st) {
      _logger.severe('Error creando perfil cliente', e, st);
      rethrow;
    }
  }

  Future<ClientProfileModel?> getClientProfile(String userId) async {
    try {
      final doc = await _ref.doc(userId).get();

      if (!doc.exists) {
        _logger.warning('No existe perfil cliente para userId: $userId');
        return null;
      }

      final data = doc.data();

      if (data == null) {
        _logger.warning('Perfil cliente sin datos para userId: $userId');
        return null;
      }

      return ClientProfileModel.fromMap(data, doc.id);
    } catch (e, st) {
      _logger.severe('Error obteniendo perfil cliente', e, st);
      return null;
    }
  }

  Future<void> updateClientProfile(ClientProfileModel profile) async {
    try {
      await _ref
          .doc(profile.userId)
          .set(profile.toMap(), SetOptions(merge: true));
      await _syncUserProfile(profile);
    } catch (e, st) {
      _logger.severe('Error actualizando perfil cliente', e, st);
      rethrow;
    }
  }

  Future<void> saveClientProfile(ClientProfileModel profile) async {
    try {
      await _ref
          .doc(profile.userId)
          .set(profile.toMap(), SetOptions(merge: true));
      await _syncUserProfile(profile);
    } catch (e, st) {
      _logger.severe('Error guardando perfil cliente', e, st);
      rethrow;
    }
  }

  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final ref = _storage.ref().child(
        'clients/$userId/profile/profile_image.jpg',
      );

      final snapshot = await ref
          .putFile(imageFile, SettableMetadata(contentType: 'image/jpeg'))
          .timeout(const Duration(seconds: 20));

      return snapshot.ref.getDownloadURL().timeout(const Duration(seconds: 10));
    } catch (e, st) {
      _logger.severe('Error subiendo foto de perfil cliente', e, st);
      rethrow;
    }
  }

  Stream<String?> watchPendingEmail(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((snap) {
      final pendingEmail = snap.data()?['pendingEmail'] as String?;
      final cleaned = pendingEmail?.trim();
      return (cleaned == null || cleaned.isEmpty) ? null : cleaned;
    });
  }

  Future<String?> getUserEmail(String userId) async {
    try {
      final userSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      final userEmail = (userSnapshot.data()?['email'] as String?)?.trim();
      if (userEmail != null && userEmail.isNotEmpty) return userEmail;

      final clientSnapshot = await _firestore
          .collection('clients')
          .doc(userId)
          .get();
      final clientEmail = (clientSnapshot.data()?['email'] as String?)?.trim();
      if (clientEmail != null && clientEmail.isNotEmpty) return clientEmail;

      return null;
    } catch (e, st) {
      _logger.severe('Error obteniendo correo del usuario cliente', e, st);
      return null;
    }
  }

  Future<void> saveUserEmail({
    required String userId,
    required String email,
  }) async {
    await _firestore.collection('users').doc(userId).set({
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _syncUserProfile(ClientProfileModel profile) async {
    await _firestore.collection('users').doc(profile.userId).set({
      'name': profile.name,
      'role': 'cliente',
      'phone': profile.phone,
      'address': profile.address,
      'profileImageUrl': profile.profileImageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
