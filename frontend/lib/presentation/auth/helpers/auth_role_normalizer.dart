class AuthRoleNormalizer {
  static String normalize(dynamic role) {
    final value = role?.toString().trim().toLowerCase() ?? '';

    switch (value) {
      case 'cliente':
      case 'client':
      case 'usuario':
        return 'cliente';

      case 'emprendedor':
      case 'entrepreneur':
      case 'business':
        return 'emprendedor';

      case 'pending_nutritionist':
        return 'pending_nutritionist';

      case 'nutricionista':
      case 'nutritionist':
        return 'nutricionista';

      case 'admin':
      case 'adm':
      case 'administrador':
        return 'admin';

      default:
        return value;
    }
  }
}