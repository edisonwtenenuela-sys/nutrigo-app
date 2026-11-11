import 'package:emprendedor/data/models/nutritionist/nutritionist_profile_model.dart';
import 'package:emprendedor/data/repositories/nutritionist/nutritionist_profile_repository.dart';
import 'package:emprendedor/core/services/auth/user_session_service.dart';

class NutritionistProfessionalRegistrationService {
  NutritionistProfessionalRegistrationService({
    NutritionistProfileRepository? repository,
    UserSessionService? sessionService,
  }) : _repository = repository ?? NutritionistProfileRepository(),
       _sessionService = sessionService ?? UserSessionService();

  final NutritionistProfileRepository _repository;
  final UserSessionService _sessionService;

  UserSessionSnapshot? currentSession() => _sessionService.currentSnapshot();

  Future<NutritionistProfileModel?> loadExistingProfile() async {
    final session = currentSession();
    if (session == null) return null;

    final profile = await _repository.getNutritionistProfile(session.uid);
    if (profile != null) return profile;

    return _repository.getVerificationRequestProfile(session.uid);
  }

  Future<void> submitRegistration({
    required UserSessionSnapshot session,
    required String name,
    required String phone,
    required String specialty,
    required String licenseNumber,
    required String professionalRegistryType,
    required String professionalDescription,
  }) {
    final email = session.email ?? '';
    final profile = NutritionistProfileModel(
      id: session.uid,
      userId: session.uid,
      name: name,
      role: 'pending_nutritionist',
      email: email,
      phone: phone,
      specialty: specialty,
      licenseNumber: licenseNumber,
      professionalRegistryType: professionalRegistryType,
      professionalDescription: professionalDescription,
      isVerified: false,
    );

    return _repository.submitProfessionalRegistration(profile, email);
  }
}








