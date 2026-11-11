class RegisterRoleDefaults {
  const RegisterRoleDefaults._();

  static String defaultNameByRole(String role) {
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

  static String roleToSaveInUsers(String selectedRole) {
    if (selectedRole == 'nutricionista') return 'pending_nutritionist';
    return selectedRole;
  }

  static bool initialVerificationValue(String selectedRole) {
    return selectedRole == 'cliente';
  }

  static String initialVerificationStatus(String selectedRole) {
    if (selectedRole == 'cliente') return 'approved';
    if (selectedRole == 'emprendedor') return 'not_submitted';
    return 'pending';
  }
}








