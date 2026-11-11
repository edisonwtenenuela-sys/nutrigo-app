import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logging/logging.dart';

import 'package:emprendedor/data/models/nutritionist/nutritionist_profile_model.dart';

class NutritionistProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Logger _logger = Logger('NutritionistProfileRepository');

  static const String _collection = 'nutritionists';

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection(_collection);

  Future<void> createNutritionistProfile(
    NutritionistProfileModel profile,
  ) async {
    try {
      await _saveProfileDocument(profile);
      await _syncUserProfile(profile);
    } catch (e, st) {
      _logger.severe('Error creando perfil de nutricionista', e, st);
      rethrow;
    }
  }

  Future<List<NutritionistProfileModel>> getAllNutritionists() async {
    try {
      final snapshot = await _ref.get();

      return snapshot.docs
          .map((doc) => NutritionistProfileModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e, st) {
      _logger.severe('Error obteniendo nutricionistas', e, st);
      return [];
    }
  }

  Stream<List<NutritionistProfileModel>> watchAllNutritionists() {
    return _ref.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => NutritionistProfileModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<NutritionistProfileModel?> watchNutritionistProfile(String userId) {
    // Combina en tiempo real el perfil de nutritionists + verificationStatus de users
    return _ref.doc(userId).snapshots().asyncMap((profileDoc) async {
      if (!profileDoc.exists || profileDoc.data() == null) return null;

      final profileData = Map<String, dynamic>.from(profileDoc.data()!);

      try {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        final userData = userDoc.data();
        final verificationStatus = userData?['verificationStatus']?.toString();
        if (verificationStatus != null && verificationStatus.isNotEmpty) {
          profileData['verificationStatus'] = verificationStatus;
        }
        final verificationMessage = userData?['verificationMessage']
            ?.toString();
        if (verificationMessage != null && verificationMessage.isNotEmpty) {
          profileData['verificationMessage'] = verificationMessage;
        }
      } catch (_) {
        // Si falla la lectura de users, igual devolvemos el perfil sin el campo
      }

      return NutritionistProfileModel.fromMap(profileData, profileDoc.id);
    });
  }

  Future<NutritionistProfileModel?> getNutritionistProfile(
    String userId,
  ) async {
    try {
      final profileDoc = await _ref
          .doc(userId)
          .get()
          .timeout(const Duration(seconds: 10));

      if (!profileDoc.exists || profileDoc.data() == null) return null;

      final profileData = Map<String, dynamic>.from(profileDoc.data()!);

      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(userId)
            .get()
            .timeout(const Duration(seconds: 8));
        final userData = userDoc.data();
        if (userData != null) {
          final verificationStatus = userData['verificationStatus']?.toString();
          if (verificationStatus != null && verificationStatus.isNotEmpty) {
            profileData['verificationStatus'] = verificationStatus;
          }
          final verificationMessage = userData['verificationMessage']
              ?.toString();
          if (verificationMessage != null && verificationMessage.isNotEmpty) {
            profileData['verificationMessage'] = verificationMessage;
          }
        }
      } on FirebaseException catch (e) {
        if (e.code != 'permission-denied') {
          _logger.warning(
            'No se pudo complementar el perfil nutricionista con users/$userId',
            e,
          );
        }
      }

      return NutritionistProfileModel.fromMap(profileData, profileDoc.id);
    } catch (e, st) {
      _logger.severe('Error obteniendo perfil nutricionista', e, st);
      return null;
    }
  }

  Future<NutritionistProfileModel?> getVerificationRequestProfile(
    String userId,
  ) async {
    try {
      final doc = await _firestore
          .collection('nutritionist_verifications')
          .doc(userId)
          .get();

      final data = doc.data();
      if (!doc.exists || data == null) return null;

      return NutritionistProfileModel.fromMap({
        ...data,
        'userId': data['userId']?.toString() ?? userId,
        'role': 'pending_nutritionist',
      }, doc.id);
    } catch (e, st) {
      _logger.severe('Error obteniendo solicitud nutricionista', e, st);
      return null;
    }
  }

  Future<void> updateNutritionistProfile(
    NutritionistProfileModel profile,
  ) async {
    try {
      await _saveProfileDocument(profile).timeout(const Duration(seconds: 12));
      await _syncUserProfile(profile).timeout(const Duration(seconds: 10));
    } catch (e, st) {
      _logger.severe('Error actualizando perfil nutricionista', e, st);
      rethrow;
    }
  }

  Future<void> saveNutritionistProfile(NutritionistProfileModel profile) async {
    try {
      await _saveProfileDocument(profile).timeout(const Duration(seconds: 12));
      await _syncUserProfile(profile).timeout(const Duration(seconds: 10));
    } catch (e, st) {
      _logger.severe('Error guardando perfil nutricionista', e, st);
      rethrow;
    }
  }

  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final ref = _storage
          .ref()
          .child('nutritionists')
          .child(userId)
          .child('profile')
          .child('profile_image.jpg');

      final snapshot = await ref
          .putFile(imageFile, SettableMetadata(contentType: 'image/jpeg'))
          .timeout(const Duration(seconds: 20));

      final imageUrl = await snapshot.ref.getDownloadURL().timeout(
        const Duration(seconds: 10),
      );

      await _ref
          .doc(userId)
          .set({
            'profileImageUrl': imageUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 12));

      await _firestore
          .collection('users')
          .doc(userId)
          .set({
            'profileImageUrl': imageUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 12));

      return imageUrl;
    } catch (e, st) {
      _logger.severe('Error subiendo foto del nutricionista', e, st);
      rethrow;
    }
  }

  Future<void> submitProfessionalRegistration(
    NutritionistProfileModel profile,
    String email,
  ) async {
    try {
      await saveNutritionistProfile(
        profile,
      ).timeout(const Duration(seconds: 15));
      await submitVerificationRequest(
        profile,
        email,
      ).timeout(const Duration(seconds: 15));

      await _firestore
          .collection('users')
          .doc(profile.userId)
          .set({
            'name': profile.name,
            'email': email,
            'phone': profile.phone,
            'licenseNumber': profile.licenseNumber,
            'professionalRegistryType': profile.professionalRegistryType,
            'professionalLicense': profile.licenseNumber,
            'role': 'pending_nutritionist',
            'requestedRole': 'nutricionista',
            'isVerified': false,
            'verificationStatus': 'pending',
            'verificationMessage': '',
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 12));
    } catch (e, st) {
      _logger.severe('Error completando registro profesional', e, st);
      rethrow;
    }
  }

  Future<void> submitVerificationRequest(
    NutritionistProfileModel profile,
    String email,
  ) async {
    try {
      await _firestore
          .collection('nutritionist_verifications')
          .doc(profile.userId)
          .set({
            'userId': profile.userId,
            'name': profile.name,
            'email': email,
            'phone': profile.phone ?? '',
            'specialty': profile.specialty ?? '',
            'professionalDescription': profile.professionalDescription ?? '',
            'licenseNumber': profile.licenseNumber ?? '',
            'professionalRegistryType': profile.professionalRegistryType ?? '',
            'professionalLicense': profile.licenseNumber ?? '',
            'status': 'pending',
            'message': '',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 12));

      await _firestore
          .collection('users')
          .doc(profile.userId)
          .set({
            'role': 'pending_nutritionist',
            'requestedRole': 'nutricionista',
            'isVerified': false,
            'verificationStatus': 'pending',
            'verificationMessage': '',
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 12));
    } catch (e, st) {
      _logger.severe(
        'Error enviando solicitud de verificación nutricionista',
        e,
        st,
      );
      rethrow;
    }
  }

  Future<void> _syncUserProfile(NutritionistProfileModel profile) async {
    await _firestore
        .collection('users')
        .doc(profile.userId)
        .set({
          'name': profile.name,
          'phone': profile.phone,
          'profileImageUrl': profile.profileImageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true))
        .timeout(const Duration(seconds: 10));
  }

  Future<void> _saveProfileDocument(NutritionistProfileModel profile) async {
    final docRef = _ref.doc(profile.userId);
    final snapshot = await docRef.get().timeout(const Duration(seconds: 8));

    await docRef
        .set(
          snapshot.exists
              ? _editableProfileMap(profile)
              : _initialProfileMap(profile),
          SetOptions(merge: true),
        )
        .timeout(const Duration(seconds: 10));
  }

  Map<String, dynamic> _initialProfileMap(NutritionistProfileModel profile) {
    return {
      ...profile.toMap(),
      'createdAt': profile.createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> _editableProfileMap(NutritionistProfileModel profile) {
    return {
      'name': profile.name,
      'email': profile.email,
      'phone': profile.phone,
      'profileImageUrl': profile.profileImageUrl,
      'specialty': profile.specialty,
      'professionalDescription': profile.professionalDescription,
      'licenseNumber': profile.licenseNumber,
      'professionalRegistryType': profile.professionalRegistryType,
      'consultationMode': profile.consultationMode.value,
      'consultationPrice': profile.consultationPrice,
      'availableDays': profile.availableDays,
      'attentionHours': profile.attentionHours,
      'meetingLink': profile.meetingLink,
      'consultationAddress': profile.consultationAddress,
      'consultationLatitude': profile.consultationLatitude,
      'consultationLongitude': profile.consultationLongitude,
      'consultationInstructions': profile.consultationInstructions,
      'isAvailable': profile.isAvailable,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
