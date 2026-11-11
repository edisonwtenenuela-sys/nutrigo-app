import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

import 'package:emprendedor/data/models/entrepreneur/profile/social_media_model.dart';

class SocialMediaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger('SocialMediaRepository');

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('social_media');
  }

  Future<void> addSocialMedia(
    String userId,
    SocialMediaModel socialMedia,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 10));

      final data = socialMedia.copyWith(
        userId: userId,
        createdAt: socialMedia.createdAt ?? Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await _collection(
        userId,
      ).add(data.toFirestore()).timeout(const Duration(seconds: 12));
      await _syncBusinessProfileLinks(userId);
    } catch (e, st) {
      _logger.severe('Error añadiendo red social', e, st);
      rethrow;
    }
  }

  Future<void> updateSocialMedia(
    String userId,
    SocialMediaModel socialMedia,
  ) async {
    if (socialMedia.id == null || socialMedia.id!.isEmpty) {
      throw Exception('ID requerido para actualizar red social.');
    }

    try {
      final docRef = _collection(userId).doc(socialMedia.id);
      final doc = await docRef
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 10));

      if (!doc.exists) {
        throw Exception('Red social no encontrada.');
      }

      final data = socialMedia.copyWith(
        userId: userId,
        updatedAt: Timestamp.now(),
      );

      await docRef
          .set(data.toFirestore(), SetOptions(merge: true))
          .timeout(const Duration(seconds: 12));
      await _syncBusinessProfileLinks(userId);
    } catch (e, st) {
      _logger.severe('Error actualizando red social', e, st);
      rethrow;
    }
  }

  Future<void> deleteSocialMedia(String userId, String docId) async {
    try {
      final docRef = _collection(userId).doc(docId);
      final doc = await docRef
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 10));

      if (!doc.exists) {
        throw Exception('Red social no encontrada.');
      }

      await docRef.delete().timeout(const Duration(seconds: 12));
      await _syncBusinessProfileLinks(userId);
    } catch (e, st) {
      _logger.severe('Error eliminando red social', e, st);
      rethrow;
    }
  }

  Stream<List<SocialMediaModel>> getSocialMediaLinks(String userId) {
    return _collection(userId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => SocialMediaModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> _syncBusinessProfileLinks(String userId) async {
    final snapshot = await _collection(userId)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 10));
    final links = <String, String>{};

    for (final doc in snapshot.docs) {
      final socialMedia = SocialMediaModel.fromFirestore(doc);
      final url = socialMedia.url.trim();
      if (url.isEmpty) continue;
      links[socialMedia.type.value] = url;
    }

    await _firestore
        .collection('business_profiles')
        .doc(userId)
        .set({
          'socialMediaLinks': links,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true))
        .timeout(const Duration(seconds: 12));
  }
}
