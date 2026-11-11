import 'package:emprendedor/data/repositories/client/client_profile_repository.dart';
import 'package:emprendedor/features/client/controllers/cart_controller.dart';
import 'package:emprendedor/core/services/auth/user_session_service.dart';

class CustomerData {
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;

  const CustomerData({
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
  });
}

class DefaultShippingLocation {
  const DefaultShippingLocation({
    required this.address,
    this.latitude,
    this.longitude,
  });

  final String address;
  final double? latitude;
  final double? longitude;

  bool get hasAddress => address.trim().isNotEmpty;
}

class CartCheckoutService {
  CartCheckoutService({
    ClientProfileRepository? clientProfileRepository,
    UserSessionService? sessionService,
  }) : _clientProfileRepository =
           clientProfileRepository ?? ClientProfileRepository(),
       _sessionService = sessionService ?? UserSessionService();

  final ClientProfileRepository _clientProfileRepository;
  final UserSessionService _sessionService;

  bool get hasAuthenticatedUser => _sessionService.currentSnapshot() != null;

  Future<DefaultShippingLocation?> loadDefaultShippingLocation() async {
    final session = _sessionService.currentSnapshot();
    if (session == null) return null;

    final profile = await _clientProfileRepository.getClientProfile(
      session.uid,
    );
    final address = profile?.address?.trim();

    if (address == null || address.isEmpty) return null;

    return DefaultShippingLocation(
      address: address,
      latitude: profile?.latitude,
      longitude: profile?.longitude,
    );
  }

  Future<CustomerData> loadCustomerData() async {
    final session = _sessionService.currentSnapshot();
    if (session == null) {
      throw StateError('Debes iniciar sesi\u00f3n para confirmar el pedido.');
    }

    final profile = await _clientProfileRepository.getClientProfile(
      session.uid,
    );
    final profileName = profile?.name.trim();
    final profilePhone = profile?.phone?.trim();
    final profileImage = profile?.profileImageUrl?.trim();

    return CustomerData(
      name: profileName == null || profileName.isEmpty
          ? 'Cliente'
          : profileName,
      email: session.email ?? 'sin-correo@local.app',
      phoneNumber: profilePhone == null || profilePhone.isEmpty
          ? null
          : profilePhone,
      profileImageUrl: profileImage == null || profileImage.isEmpty
          ? null
          : profileImage,
    );
  }

  String? validateCheckoutInputs({
    required CartController cart,
    required bool hasAuthenticatedUser,
    required String shippingAddress,
    required String? selectedPaymentMethod,
  }) {
    if (!hasAuthenticatedUser) {
      return 'Debes iniciar sesi\u00f3n para confirmar el pedido.';
    }
    if (cart.items.isEmpty) {
      return 'Tu carrito est\u00e1 vac\u00edo.';
    }
    if (shippingAddress.trim().isEmpty) {
      return 'Ingresa una direcci\u00f3n de env\u00edo.';
    }
    if (selectedPaymentMethod == null) {
      return 'Selecciona un m\u00e9todo de pago.';
    }
    return null;
  }
}








