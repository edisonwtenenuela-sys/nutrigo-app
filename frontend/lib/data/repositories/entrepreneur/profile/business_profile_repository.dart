import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

import 'package:emprendedor/data/models/entrepreneur/profile/business_profile_model.dart';

class BusinessProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger('BusinessProfileRepository');

  static const String _collection = 'business_profiles';

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection(_collection);

  Future<BusinessProfileModel?> getBusinessProfile(String userId) async {
    try {
      final doc = await _ref.doc(userId).get();

      if (!doc.exists || doc.data() == null) return null;

      return BusinessProfileModel.fromFirestore(doc);
    } catch (e, st) {
      _logger.severe('Error obteniendo perfil de negocio', e, st);
      return null;
    }
  }

  Stream<BusinessProfileModel?> watchBusinessProfile(String userId) {
    if (userId.trim().isEmpty) {
      return Stream.value(null);
    }

    return _ref.doc(userId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return BusinessProfileModel.fromFirestore(doc);
    });
  }

  Future<BusinessProfileModel> createBusinessProfile(
    BusinessProfileModel profile,
  ) async {
    final userId = profile.userId;

    if (userId == null || userId.isEmpty) {
      throw Exception('El userId es requerido para crear el perfil.');
    }

    try {
      final profileToSave = profile.copyWith(
        id: userId,
        createdAt: profile.createdAt ?? Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await _saveProfileWithUserSync(profileToSave);

      return profileToSave;
    } catch (e, st) {
      _logger.severe('Error creando perfil de negocio', e, st);
      rethrow;
    }
  }

  Future<void> updateBusinessProfile(BusinessProfileModel profile) async {
    final userId = profile.userId;

    if (userId == null || userId.isEmpty) {
      throw Exception('El userId es requerido para actualizar el perfil.');
    }

    try {
      final profileToUpdate = profile.copyWith(updatedAt: Timestamp.now());
      await _saveProfileWithUserSync(profileToUpdate);
    } catch (e, st) {
      _logger.severe('Error actualizando perfil de negocio', e, st);
      rethrow;
    }
  }

  Future<void> saveBusinessProfile(BusinessProfileModel profile) async {
    final userId = profile.userId;

    if (userId == null || userId.isEmpty) {
      throw Exception('El userId es requerido para guardar el perfil.');
    }

    try {
      final profileToSave = profile.copyWith(updatedAt: Timestamp.now());
      await _saveProfileWithUserSync(profileToSave);
    } catch (e, st) {
      _logger.severe('Error guardando perfil de negocio', e, st);
      rethrow;
    }
  }

  Future<
    ({BusinessProfileModel? profile, String? representativeName, String? email})
  >
  loadInitialSetupDraft(String userId) async {
    final profile = await getBusinessProfile(userId);
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data() ?? <String, dynamic>{};

    var representativeName = userData['representativeName']?.toString().trim();
    var email = userData['email']?.toString().trim();

    if (profile != null) {
      return (
        profile: profile,
        representativeName: representativeName,
        email: email,
      );
    }

    try {
      final verificationDoc = await _firestore
          .collection('entrepreneur_verifications')
          .doc(userId)
          .get();
      final data = verificationDoc.data();
      if (!verificationDoc.exists || data == null) {
        return (
          profile: null,
          representativeName: representativeName,
          email: email,
        );
      }

      representativeName = _firstNonEmpty([
        data['representativeName'],
        data['ownerName'],
        representativeName,
      ]);
      email = _firstNonEmpty([data['email'], email]);

      return (
        profile: BusinessProfileModel(
          id: userId,
          userId: userId,
          name: data['businessName']?.toString() ?? '',
          role: 'emprendedor',
          description: data['description']?.toString(),
          documentType: data['documentType']?.toString(),
          documentNumber: data['documentNumber']?.toString(),
          address: data['address']?.toString(),
          phone: data['phone']?.toString(),
        ),
        representativeName: representativeName,
        email: email,
      );
    } catch (e, st) {
      _logger.severe('Error obteniendo borrador de negocio', e, st);
      return (
        profile: null,
        representativeName: representativeName,
        email: email,
      );
    }
  }

  String? _firstNonEmpty(List<Object?> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  Future<({String? email, bool isVerified})> loadUserProfileMetadata({
    required String userId,
    String? fallbackEmail,
  }) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data();
    final firestoreEmail = data?['email']?.toString().trim();
    final email = (fallbackEmail?.trim().isNotEmpty ?? false)
        ? fallbackEmail!.trim()
        : firestoreEmail;
    final isVerified =
        data?['isVerified'] == true ||
        data?['verificationStatus']?.toString() == 'approved';

    return (email: email, isVerified: isVerified);
  }

  Future<void> updateContactEmail({
    required String userId,
    required String email,
  }) async {
    await _firestore.collection('users').doc(userId).set({
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> submitInitialSetup({
    required BusinessProfileModel profile,
    required String representativeName,
    required String email,
  }) async {
    final userId = profile.userId;

    if (userId == null || userId.isEmpty) {
      throw Exception('El userId es requerido para completar el perfil.');
    }

    try {
      final profileToSave = profile.copyWith(
        id: userId,
        createdAt: profile.createdAt ?? Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      final batch = _firestore.batch();

      batch.set(
        _ref.doc(userId),
        profileToSave.toFirestore(deleteNullLocation: true),
        SetOptions(merge: true),
      );

      batch.set(_firestore.collection('users').doc(userId), {
        'name': profileToSave.name,
        'representativeName': representativeName,
        'email': email,
        'phone': profileToSave.phone,
        'address': profileToSave.address,
        'documentType': profileToSave.documentType,
        'documentNumber': profileToSave.documentNumber,
        'role': 'emprendedor',
        'requestedRole': 'emprendedor',
        'isVerified': false,
        'verificationStatus': 'pending',
        'verificationMessage': '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      batch.set(
        _firestore.collection('entrepreneur_verifications').doc(userId),
        {
          'entrepreneurId': userId,
          'userId': userId,
          'businessName': profileToSave.name,
          'ownerName': representativeName,
          'representativeName': representativeName,
          'email': email,
          'phone': profileToSave.phone,
          'address': profileToSave.address,
          'documentType': profileToSave.documentType,
          'documentNumber': profileToSave.documentNumber,
          'status': 'pending',
          'message': '',
          'resubmittedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await batch.commit();
    } catch (e, st) {
      _logger.severe('Error completando perfil inicial de negocio', e, st);
      rethrow;
    }
  }

  Future<void> deleteBusinessProfile(String userId) async {
    if (userId.isEmpty) return;

    try {
      await _ref.doc(userId).delete();
    } catch (e, st) {
      _logger.severe('Error eliminando perfil de negocio', e, st);
      rethrow;
    }
  }

  Future<void> _saveProfileWithUserSync(BusinessProfileModel profile) async {
    final userId = profile.userId;

    if (userId == null || userId.isEmpty) return;

    final batch = _firestore.batch();

    batch.set(
      _ref.doc(userId),
      profile.toFirestore(deleteNullLocation: true),
      SetOptions(merge: true),
    );

    batch.set(_firestore.collection('users').doc(userId), {
      'name': profile.name,
      'role': 'emprendedor',
      'phone': profile.phone,
      'address': profile.address,
      'documentType': profile.documentType,
      'documentNumber': profile.documentNumber,
      'profileImageUrl': profile.profileImageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
  }
}
