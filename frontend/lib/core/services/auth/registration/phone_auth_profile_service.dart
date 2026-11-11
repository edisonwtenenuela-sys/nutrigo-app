import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emprendedor/core/utils/professional_registry_utils.dart';
import 'package:emprendedor/data/models/client/client_profile_model.dart';
import 'package:emprendedor/data/models/entrepreneur/profile/business_profile_model.dart';
import 'package:emprendedor/data/models/nutritionist/nutritionist_profile_model.dart';
import 'package:emprendedor/data/repositories/client/client_profile_repository.dart';
import 'package:emprendedor/data/repositories/entrepreneur/profile/business_profile_repository.dart';
import 'package:emprendedor/data/repositories/nutritionist/nutritionist_profile_repository.dart';

class PhoneAuthProfileService {
  PhoneAuthProfileService({
    FirebaseFirestore? firestore,
    BusinessProfileRepository? businessRepo,
    ClientProfileRepository? clientRepo,
    NutritionistProfileRepository? nutritionistRepo,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
        _businessRepo = businessRepo ?? BusinessProfileRepository(),
        _clientRepo = clientRepo ?? ClientProfileRepository(),
        _nutritionistRepo = nutritionistRepo ?? NutritionistProfileRepository();

  static const String _ecuadorPhoneCode = '+593';

  final FirebaseFirestore _firestore;
  final BusinessProfileRepository _businessRepo;
  final ClientProfileRepository _clientRepo;
  final NutritionistProfileRepository _nutritionistRepo;

  String _defaultNameByRole(String role) {
    switch (role) {
      case 'cliente':
        return 'Nuevo Cliente';
      case 'nutricionista':
        return 'Nuevo Nutricionista';
      case 'emprendedor':
      default:
        return 'Nuevo Emprendedor';
    }
  }

  String _fullEcuadorPhone(String phone) {
    return '$_ecuadorPhoneCode$phone';
  }

  Future<void> initializePhoneAuthUser({
    required String selectedRole,
    required String userId,
    required String phoneCode,
    required String phone,
  }) async {
    final fullPhoneNumber = _fullEcuadorPhone(phone);
    final normalizedRole = selectedRole == 'nutricionista'
        ? 'pending_nutritionist'
        : selectedRole;
    final verificationStatus = selectedRole == 'cliente'
        ? 'approved'
        : 'not_submitted';

    await _firestore.collection('users').doc(userId).set({
      'role': normalizedRole,
      'requestedRole': selectedRole,
      'phone': fullPhoneNumber,
      'phoneCode': _ecuadorPhoneCode,
      'country': 'Ecuador',
      'isVerified': selectedRole == 'cliente',
      'verificationStatus': verificationStatus,
      'verificationMessage': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveProfileByRole({
    required String selectedRole,
    required String userId,
    required String name,
    required String phoneCode,
    required String phone,
    required String address,
    required String ageText,
    required String dietaryGoal,
    required String documentType,
    required String documentNumber,
    required String businessDescription,
    required String specialty,
    required String licenseNumber,
    required String professionalDescription,
    String contactEmail = '',
  }) async {
    final defaultName = name.isNotEmpty
        ? name
        : _defaultNameByRole(selectedRole);
    final fullPhoneNumber = _fullEcuadorPhone(phone);
    final userRef = _firestore.collection('users').doc(userId);

    switch (selectedRole) {
      case 'cliente':
        await userRef.set({
          'role': 'cliente',
          'requestedRole': 'cliente',
          'name': defaultName,
          'phone': fullPhoneNumber,
          'phoneCode': _ecuadorPhoneCode,
          'country': 'Ecuador',
          'address': address,
          'isVerified': true,
          'verificationStatus': 'approved',
          'verificationMessage': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await _clientRepo.createClientProfile(
          ClientProfileModel(
            userId: userId,
            name: defaultName,
            role: 'cliente',
            phone: fullPhoneNumber,
            address: address,
            age: int.tryParse(ageText),
            dietaryGoal: dietaryGoal,
            isVerified: true,
          ),
        );
        break;

      case 'nutricionista':
        await userRef.set({
          'role': 'pending_nutritionist',
          'requestedRole': 'nutricionista',
          'name': defaultName,
          'email': contactEmail,
          'phone': fullPhoneNumber,
          'phoneCode': _ecuadorPhoneCode,
          'country': 'Ecuador',
          'licenseNumber': licenseNumber,
          'professionalRegistryType': ProfessionalRegistryUtils.msp,
          'professionalLicense': licenseNumber,
          'isVerified': false,
          'verificationStatus': 'pending',
          'verificationMessage': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await _nutritionistRepo.createNutritionistProfile(
          NutritionistProfileModel(
            userId: userId,
            name: defaultName,
            role: 'pending_nutritionist',
            email: contactEmail,
            isVerified: false,
            phone: fullPhoneNumber,
            specialty: specialty,
            licenseNumber: licenseNumber,
            professionalRegistryType: ProfessionalRegistryUtils.msp,
            professionalDescription: professionalDescription,
          ),
        );

        await createNutritionistVerificationIfMissing(
          userId: userId,
          name: defaultName,
          email: contactEmail,
          phone: fullPhoneNumber,
          specialty: specialty,
          licenseNumber: licenseNumber,
          professionalDescription: professionalDescription,
        );
        break;

      case 'emprendedor':
      default:
        await userRef.set({
          'role': 'emprendedor',
          'requestedRole': 'emprendedor',
          'name': defaultName,
          'email': contactEmail,
          'phone': fullPhoneNumber,
          'phoneCode': _ecuadorPhoneCode,
          'country': 'Ecuador',
          'address': address,
          'documentType': documentType,
          'documentNumber': documentNumber,
          'isVerified': false,
          'verificationStatus': 'not_submitted',
          'verificationMessage': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await _businessRepo.createBusinessProfile(
          BusinessProfileModel(
            userId: userId,
            name: defaultName,
            role: 'emprendedor',
            phone: fullPhoneNumber,
            address: address,
            documentType: documentType,
            documentNumber: documentNumber,
            description: businessDescription,
          ),
        );
        break;
    }
  }

  Future<void> createNutritionistVerificationIfMissing({
    required String userId,
    required String name,
    required String email,
    required String phone,
    required String specialty,
    required String licenseNumber,
    required String professionalDescription,
  }) async {
    final verificationRef = _firestore
        .collection('nutritionist_verifications')
        .doc(userId);
    final verificationSnap = await verificationRef.get();

    if (verificationSnap.exists) return;

    await verificationRef.set({
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'phoneCode': _ecuadorPhoneCode,
      'country': 'Ecuador',
      'specialty': specialty,
      'professionalDescription': professionalDescription,
      'licenseNumber': licenseNumber,
      'professionalRegistryType': ProfessionalRegistryUtils.msp,
      'professionalLicense': licenseNumber,
      'status': 'pending',
      'message': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> ensureNutritionistVerificationRequest({
    required String selectedRole,
    required String userId,
    required String fallbackName,
    required String fallbackEmail,
    required String phoneCode,
    required String phone,
    required String specialty,
    required String licenseNumber,
    required String professionalDescription,
  }) async {
    if (selectedRole != 'nutricionista') return;

    final userRef = _firestore.collection('users').doc(userId);
    final userSnap = await userRef.get();
    final userData = userSnap.data() ?? <String, dynamic>{};
    final currentStatus = (userData['verificationStatus'] as String?) ?? '';

    if (currentStatus == 'approved') return;

    final resolvedName =
    ((userData['name'] as String?)?.trim().isNotEmpty ?? false)
        ? (userData['name'] as String).trim()
        : fallbackName;
    final resolvedEmail =
    ((userData['email'] as String?)?.trim().isNotEmpty ?? false)
        ? (userData['email'] as String).trim()
        : fallbackEmail;
    final fullPhoneNumber = _fullEcuadorPhone(phone);

    await userRef.set({
      'role': 'pending_nutritionist',
      'requestedRole': 'nutricionista',
      'phone': fullPhoneNumber,
      'phoneCode': _ecuadorPhoneCode,
      'country': 'Ecuador',
      'verificationStatus': 'pending',
      'isVerified': false,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await createNutritionistVerificationIfMissing(
      userId: userId,
      name: resolvedName,
      email: resolvedEmail,
      phone: fullPhoneNumber,
      specialty: specialty,
      licenseNumber: licenseNumber,
      professionalDescription: professionalDescription,
    );
  }
}