import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:emprendedor/core/services/auth/user_session_service.dart';

class BusinessVerificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserSessionService _sessionService = UserSessionService();
  static final Map<String, Map<String, dynamic>> _verificationCache = {};

  String? currentUserId() => _sessionService.currentUserId();

  Map<String, dynamic>? cachedVerificationData() {
    final userId = _sessionService.currentUserId();
    if (userId == null) return null;
    return _verificationCache[userId];
  }

  Stream<Map<String, dynamic>?> watchVerificationData() {
    final userId = _sessionService.currentUserId();
    if (userId == null) return Stream.value(null);

    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      final data = doc.data();
      if (data != null) _verificationCache[userId] = data;
      return data;
    });
  }

  Future<Map<String, dynamic>?> loadVerificationData() async {
    final userId = _sessionService.currentUserId();
    if (userId == null) return null;

    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data();
    if (data != null) _verificationCache[userId] = data;
    return data;
  }

  String _readString(Map<String, dynamic>? data, String key) {
    final value = data?[key];
    if (value == null) return '';
    return value.toString().trim();
  }

  Future<void> submitVerificationRequest(Map<String, dynamic>? userData) async {
    final session = _sessionService.currentSnapshot();

    if (session == null || userData == null) {
      throw Exception('Usuario no autenticado.');
    }

    final businessDoc = await _firestore
        .collection('business_profiles')
        .doc(session.uid)
        .get();

    final businessData = businessDoc.data();

    final representativeFromUser = _readString(userData, 'representativeName');
    final ownerFromUser = _readString(userData, 'ownerName');
    final userDisplayName = (session.displayName ?? '').trim();

    final businessNameFromProfile = _readString(businessData, 'name');
    final businessNameFromUser = _readString(userData, 'businessName');
    final fallbackNameFromUser = _readString(userData, 'name');

    final businessName = businessNameFromProfile.isNotEmpty
        ? businessNameFromProfile
        : businessNameFromUser.isNotEmpty
        ? businessNameFromUser
        : fallbackNameFromUser;

    final ownerName = representativeFromUser.isNotEmpty
        ? representativeFromUser
        : ownerFromUser.isNotEmpty
        ? ownerFromUser
        : userDisplayName;

    final emailFromUser = _readString(userData, 'email');
    final email = emailFromUser.isNotEmpty
        ? emailFromUser
        : (session.email ?? '').trim();

    final phoneFromProfile = _readString(businessData, 'phone');
    final phone = phoneFromProfile.isNotEmpty
        ? phoneFromProfile
        : _readString(userData, 'phone');

    final addressFromProfile = _readString(businessData, 'address');
    final address = addressFromProfile.isNotEmpty
        ? addressFromProfile
        : _readString(userData, 'address');

    final documentTypeFromProfile = _readString(businessData, 'documentType');
    final documentType = documentTypeFromProfile.isNotEmpty
        ? documentTypeFromProfile
        : _readString(userData, 'documentType');

    final documentNumberFromProfile = _readString(
      businessData,
      'documentNumber',
    );
    final documentNumber = documentNumberFromProfile.isNotEmpty
        ? documentNumberFromProfile
        : _readString(userData, 'documentNumber');

    await _firestore
        .collection('entrepreneur_verifications')
        .doc(session.uid)
        .set({
          'entrepreneurId': session.uid,
          'userId': session.uid,
          'businessName': businessName,
          'ownerName': ownerName,
          'representativeName': ownerName,
          'email': email,
          'phone': phone,
          'address': address,
          'documentType': documentType,
          'documentNumber': documentNumber,
          'status': 'pending',
          'message': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

    await _firestore.collection('users').doc(session.uid).update({
      'verificationStatus': 'pending',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
