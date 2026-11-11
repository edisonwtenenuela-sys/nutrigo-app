import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/auth/helpers/register_role_defaults.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class RegisterRoleHelper {
  static String defaultNameByRole(String role) {
    return RegisterRoleDefaults.defaultNameByRole(role);
  }

  static String roleToSaveInUsers(String selectedRole) {
    return RegisterRoleDefaults.roleToSaveInUsers(selectedRole);
  }

  static bool initialVerificationValue(String selectedRole) {
    return RegisterRoleDefaults.initialVerificationValue(selectedRole);
  }

  static String initialVerificationStatus(String selectedRole) {
    return RegisterRoleDefaults.initialVerificationStatus(selectedRole);
  }

  static RolePalette palette(String selectedRole) => switch (selectedRole) {
    'cliente' => RoleTheme.client,
    'nutricionista' => RoleTheme.nutritionist,
    _ => RoleTheme.entrepreneur,
  };

  static AppFeedbackRole feedbackRole(String selectedRole) =>
      switch (selectedRole) {
        'cliente' => AppFeedbackRole.client,
        'nutricionista' => AppFeedbackRole.nutritionist,
        _ => AppFeedbackRole.entrepreneur,
      };
}