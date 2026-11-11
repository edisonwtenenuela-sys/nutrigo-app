import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:emprendedor/core/utils/professional_registry_utils.dart';
import 'package:emprendedor/data/models/client/client_profile_model.dart';
import 'package:emprendedor/data/models/entrepreneur/profile/business_profile_model.dart';
import 'package:emprendedor/data/models/nutritionist/nutritionist_profile_model.dart';
import 'package:emprendedor/data/repositories/client/client_profile_repository.dart';
import 'package:emprendedor/data/repositories/entrepreneur/profile/business_profile_repository.dart';
import 'package:emprendedor/data/repositories/nutritionist/nutritionist_profile_repository.dart';

class RegisterAccountService {
  RegisterAccountService({
    BusinessProfileRepository? businessRepo,
    ClientProfileRepository? clientRepo,
    NutritionistProfileRepository? nutritionistRepo,
  }) : _businessRepo = businessRepo ?? BusinessProfileRepository(),
       _clientRepo = clientRepo ?? ClientProfileRepository(),
       _nutritionistRepo = nutritionistRepo ?? NutritionistProfileRepository();

  final BusinessProfileRepository _businessRepo;
  final ClientProfileRepository _clientRepo;
  final NutritionistProfileRepository _nutritionistRepo;

  String defaultNameByRole(String role) {
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

  String roleToSaveInUsers(String selectedRole) {
    if (selectedRole == 'nutricionista') return 'pending_nutritionist';
    return selectedRole;
  }

  bool initialVerificationValue(String selectedRole) {
    if (selectedRole == 'cliente') return true;
    return false;
  }

  String initialVerificationStatus(String selectedRole) {
    if (selectedRole == 'cliente') return 'approved';
    return 'pending';
  }

  Future<void> saveUserDocument({
    required String selectedRole,
    required String userId,
    required String email,
    required String name,
    required String phone,
    required String address,
    required String documentType,
    required String documentNumber,
    required String licenseNumber,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      if (selectedRole == 'emprendedor') ...{
        'documentType': documentType,
        'documentNumber': documentNumber,
      },
      if (selectedRole == 'nutricionista') ...{
        'licenseNumber': licenseNumber,
        'professionalRegistryType': ProfessionalRegistryUtils.msp,
        'professionalLicense': licenseNumber,
      },
      'role': roleToSaveInUsers(selectedRole),
      'requestedRole': selectedRole,
      'isVerified': initialVerificationValue(selectedRole),
      'verificationStatus': initialVerificationStatus(selectedRole),
      'verificationMessage': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> createNutritionistVerificationRequest({
    required String userId,
    required String email,
    required String name,
    required String phone,
    required String specialty,
    required String professionalDescription,
    required String licenseNumber,
  }) async {
    await FirebaseFirestore.instance
        .collection('nutritionist_verifications')
        .doc(userId)
        .set({
          'userId': userId,
          'name': name,
          'email': email,
          'phone': phone,
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

  Future<void> saveProfileByRole({
    required String selectedRole,
    required String userId,
    required String email,
    required String name,
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
  }) async {
    final defaultName = name.isNotEmpty
        ? name
        : defaultNameByRole(selectedRole);

    switch (selectedRole) {
      case 'cliente':
        await _clientRepo.createClientProfile(
          ClientProfileModel(
            userId: userId,
            name: defaultName,
            role: 'cliente',
            phone: phone,
            address: address,
            age: int.tryParse(ageText),
            dietaryGoal: dietaryGoal,
            isVerified: true,
          ),
        );
        break;
      case 'nutricionista':
        await _nutritionistRepo.createNutritionistProfile(
          NutritionistProfileModel(
            userId: userId,
            name: defaultName,
            role: 'pending_nutritionist',
            email: email,
            isVerified: false,
            phone: phone,
            specialty: specialty,
            licenseNumber: licenseNumber,
            professionalRegistryType: ProfessionalRegistryUtils.msp,
            professionalDescription: professionalDescription,
          ),
        );
        await createNutritionistVerificationRequest(
          userId: userId,
          email: email,
          name: defaultName,
          phone: phone,
          specialty: specialty,
          professionalDescription: professionalDescription,
          licenseNumber: licenseNumber,
        );
        break;
      case 'emprendedor':
      default:
        await _businessRepo.createBusinessProfile(
          BusinessProfileModel(
            userId: userId,
            name: defaultName,
            role: 'emprendedor',
            phone: phone,
            address: address,
            documentType: documentType,
            documentNumber: documentNumber,
            description: businessDescription,
          ),
        );
        break;
    }
  }
}








