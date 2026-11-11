import 'package:emprendedor/data/models/entrepreneur/profile/business_profile_model.dart';
import 'package:emprendedor/data/repositories/entrepreneur/profile/business_profile_repository.dart';
import 'package:emprendedor/core/services/auth/user_session_service.dart';

class EntrepreneurProfileSetupService {
  EntrepreneurProfileSetupService({
    BusinessProfileRepository? repository,
    UserSessionService? sessionService,
  }) : _repository = repository ?? BusinessProfileRepository(),
       _sessionService = sessionService ?? UserSessionService();

  final BusinessProfileRepository _repository;
  final UserSessionService _sessionService;

  UserSessionSnapshot? currentSession() => _sessionService.currentSnapshot();

  Future<
    ({BusinessProfileModel? profile, String? representativeName, String? email})
  >
  loadInitialSetupDraft(String userId) {
    return _repository.loadInitialSetupDraft(userId);
  }

  Future<void> submitInitialSetup({
    required String userId,
    required String representativeName,
    required String businessName,
    required String documentType,
    required String documentNumber,
    required String description,
    required String address,
    required String phone,
    required String email,
  }) {
    final profile = BusinessProfileModel(
      userId: userId,
      name: businessName,
      role: 'emprendedor',
      documentType: documentType,
      documentNumber: documentNumber,
      description: description,
      address: address,
      phone: phone,
    );

    return _repository.submitInitialSetup(
      profile: profile,
      representativeName: representativeName,
      email: email,
    );
  }
}








