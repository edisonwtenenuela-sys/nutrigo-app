import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

import 'package:emprendedor/data/models/client/client_profile_model.dart';
import 'package:emprendedor/data/models/entrepreneur/profile/business_profile_model.dart';
import 'package:emprendedor/data/models/nutritionist/nutritionist_profile_model.dart';
import 'package:emprendedor/data/repositories/client/client_profile_repository.dart';
import 'package:emprendedor/data/repositories/entrepreneur/profile/business_profile_repository.dart';
import 'package:emprendedor/data/repositories/nutritionist/nutritionist_profile_repository.dart';

class AuthController {
  static const Duration _profileFetchTimeout = Duration(seconds: 8);
  static const int _profileFetchAttempts = 3;
  static const Duration _profileRetryDelay = Duration(milliseconds: 350);

  static const Set<String> _adminRoleAliases = {
    'admin',
    'adm',
    'administrador',
  };

  static const Set<String> _entrepreneurRoleAliases = {
    'emprendedor',
    'entrepreneur',
    'business',
  };

  static const Set<String> _clientRoleAliases = {'cliente', 'client'};

  static const Set<String> _nutritionistRoleAliases = {
    'nutricionista',
    'nutritionist',
  };

  final Logger _logger = Logger('AuthController');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final BusinessProfileRepository _businessRepo = BusinessProfileRepository();
  final ClientProfileRepository _clientRepo = ClientProfileRepository();
  final NutritionistProfileRepository _nutritionistRepo =
      NutritionistProfileRepository();

  Future<Map<String, dynamic>?> loadProfile(String userId) async {
    for (var attempt = 1; attempt <= _profileFetchAttempts; attempt++) {
      try {
        return await _loadProfileOnce(userId);
      } catch (e, st) {
        final isLastAttempt = attempt == _profileFetchAttempts;

        if (isLastAttempt) {
          _logger.severe('Error cargando perfil', e, st);
          return null;
        }

        _logger.warning(
          'Reintentando carga de perfil ($attempt/$_profileFetchAttempts)',
          e,
        );
        await Future<void>.delayed(_profileRetryDelay * attempt);
      }
    }

    return null;
  }

  Future<Map<String, dynamic>?> _loadProfileOnce(String userId) async {
    final userDoc = await _firestore
        .collection('users')
        .doc(userId)
        .get()
        .timeout(_profileFetchTimeout);

    if (!userDoc.exists || userDoc.data() == null) {
      return null;
    }

    final userData = userDoc.data()!;
    final role = _normalizeRole(userData['role']?.toString());

    return switch (role) {
      _CanonicalRole.admin => _buildAdminProfile(userId, userData),
      _CanonicalRole.entrepreneur => await _buildEntrepreneurProfile(
        userId,
        userData,
      ).timeout(_profileFetchTimeout),
      _CanonicalRole.client => await _buildClientProfile(
        userId,
        userData,
      ).timeout(_profileFetchTimeout),
      _CanonicalRole.pendingNutritionist =>
        await _buildPendingNutritionistProfile(
          userId,
          userData,
        ).timeout(_profileFetchTimeout),
      _CanonicalRole.nutritionist => await _buildNutritionistProfile(
        userId,
        userData,
      ).timeout(_profileFetchTimeout),
      _CanonicalRole.unknown => null,
    };
  }

  _CanonicalRole _normalizeRole(String? rawRole) {
    final role = rawRole?.trim().toLowerCase() ?? '';

    if (_adminRoleAliases.contains(role)) return _CanonicalRole.admin;
    if (_entrepreneurRoleAliases.contains(role)) {
      return _CanonicalRole.entrepreneur;
    }
    if (_clientRoleAliases.contains(role)) return _CanonicalRole.client;
    if (role == 'pending_nutritionist') {
      return _CanonicalRole.pendingNutritionist;
    }
    if (_nutritionistRoleAliases.contains(role)) {
      return _CanonicalRole.nutritionist;
    }

    return _CanonicalRole.unknown;
  }

  Map<String, dynamic> _buildAdminProfile(
    String userId,
    Map<String, dynamic> userData,
  ) {
    return {
      'role': 'admin',
      'profile': {
        'id': userId,
        'name': userData['name']?.toString() ?? 'Administrador',
        'email': userData['email']?.toString() ?? '',
        'role': 'admin',
      },
    };
  }

  Future<Map<String, dynamic>> _buildEntrepreneurProfile(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    final business = await _businessRepo.getBusinessProfile(userId);

    return {
      'role': 'emprendedor',
      'profile':
          business ??
          BusinessProfileModel(
            userId: userId,
            name: userData['name']?.toString() ?? '',
            role: 'emprendedor',
          ),
    };
  }

  Future<Map<String, dynamic>> _buildClientProfile(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    final client = await _clientRepo.getClientProfile(userId);

    return {
      'role': 'cliente',
      'profile':
          client ??
          ClientProfileModel(
            id: userId,
            userId: userId,
            name: userData['name']?.toString() ?? '',
            role: 'cliente',
            phone: userData['phone']?.toString(),
            address: userData['address']?.toString(),
            dietaryGoal: userData['dietaryGoal']?.toString(),
            gender: userData['gender']?.toString(),
            age: _toInt(userData['age']),
          ),
    };
  }

  Future<Map<String, dynamic>> _buildPendingNutritionistProfile(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    final nutritionist = await _nutritionistRepo.getNutritionistProfile(userId);

    return {
      'role': 'pending_nutritionist',
      'profile':
          nutritionist ??
          NutritionistProfileModel(
            id: userId,
            userId: userId,
            name: userData['name']?.toString() ?? '',
            role: 'pending_nutritionist',
            isVerified: false,
          ),
    };
  }

  Future<Map<String, dynamic>> _buildNutritionistProfile(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    final nutritionist = await _nutritionistRepo.getNutritionistProfile(userId);

    return {
      'role': 'nutricionista',
      'profile':
          nutritionist ??
          NutritionistProfileModel(
            id: userId,
            userId: userId,
            name: userData['name']?.toString() ?? '',
            role: 'nutricionista',
            isVerified: true,
          ),
    };
  }

  bool isEntrepreneurComplete(BusinessProfileModel profile) {
    return profile.name.trim().isNotEmpty &&
        profile.description?.trim().isNotEmpty == true &&
        profile.address?.trim().isNotEmpty == true &&
        profile.documentNumber?.trim().isNotEmpty == true &&
        profile.documentType?.trim().isNotEmpty == true &&
        profile.phone?.trim().isNotEmpty == true;
  }

  bool isClientComplete(ClientProfileModel profile) {
    return profile.name.trim().isNotEmpty &&
        profile.phone?.trim().isNotEmpty == true &&
        profile.address?.trim().isNotEmpty == true &&
        profile.dietaryGoal?.trim().isNotEmpty == true &&
        profile.gender?.trim().isNotEmpty == true &&
        profile.age != null &&
        profile.age! > 0;
  }

  bool isNutritionistComplete(NutritionistProfileModel profile) {
    return profile.name.trim().isNotEmpty &&
        profile.phone?.trim().isNotEmpty == true &&
        profile.specialty?.trim().isNotEmpty == true &&
        profile.professionalDescription?.trim().isNotEmpty == true &&
        profile.licenseNumber?.trim().isNotEmpty == true &&
        profile.consultationPrice != null &&
        profile.consultationPrice! > 0;
  }

  bool isNutritionistProfessionalRegistrationComplete(
    NutritionistProfileModel profile,
  ) {
    return profile.name.trim().isNotEmpty &&
        profile.phone?.trim().isNotEmpty == true &&
        profile.specialty?.trim().isNotEmpty == true &&
        profile.professionalDescription?.trim().isNotEmpty == true &&
        profile.licenseNumber?.trim().isNotEmpty == true &&
        profile.professionalRegistryType?.trim().isNotEmpty == true;
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

enum _CanonicalRole {
  admin,
  entrepreneur,
  client,
  pendingNutritionist,
  nutritionist,
  unknown,
}
