import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectedLocationResult {
  const SelectedLocationResult({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String address;
  final double latitude;
  final double longitude;
}

class ClientLocationPickerFeedback {
  const ClientLocationPickerFeedback({
    required this.title,
    required this.message,
    required this.isError,
  });

  final String title;
  final String message;
  final bool isError;
}

class ClientLocationPickerController extends ChangeNotifier {
  ClientLocationPickerController({
    String? initialAddress,
    double? initialLatitude,
    double? initialLongitude,
    bool useCurrentLocationAsInitial = true,
  }) : _initialAddress = initialAddress,
       _initialLatitude = initialLatitude,
       _initialLongitude = initialLongitude,
       _useCurrentLocationAsInitial = useCurrentLocationAsInitial;

  final String? _initialAddress;
  final double? _initialLatitude;
  final double? _initialLongitude;
  final bool _useCurrentLocationAsInitial;
  static const fallbackPosition = LatLng(-2.170998, -79.922359);
  static const initialAddress =
      'Toca el mapa para seleccionar una ubicaci\u00f3n';
  static const selectedAddressFallback = 'Ubicaci\u00f3n seleccionada';

  LatLng initialPosition = fallbackPosition;
  LatLng? selectedPosition;
  String selectedAddress = initialAddress;
  bool isLoading = true;
  bool isResolvingAddress = false;
  bool hasLocationPermission = false;

  bool get canConfirm => selectedPosition != null && !isResolvingAddress;

  Set<Marker> get markers {
    final position = selectedPosition;
    if (position == null) return <Marker>{};

    return {
      Marker(markerId: const MarkerId('selected_location'), position: position),
    };
  }

  SelectedLocationResult? get result {
    final position = selectedPosition;
    if (position == null) return null;

    return SelectedLocationResult(
      address: selectedAddress,
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  Future<void> loadInitialPosition() async {
    final initialLatitude = _initialLatitude;
    final initialLongitude = _initialLongitude;

    if (initialLatitude != null && initialLongitude != null) {
      final position = LatLng(initialLatitude, initialLongitude);
      final address = _initialAddress?.trim();

      initialPosition = position;
      selectedPosition = position;
      selectedAddress = address == null || address.isEmpty
          ? selectedAddressFallback
          : address;
      isLoading = false;
      notifyListeners();
      return;
    }

    if (!_useCurrentLocationAsInitial) {
      _setPosition(fallbackPosition);
      return;
    }

    await Future.any([
      _loadCurrentLocationAsInitialPosition(),
      Future.delayed(const Duration(seconds: 6), () {
        if (!isLoading) return;
        _setPosition(fallbackPosition);
      }),
    ]);
  }

  Future<ClientLocationPickerFeedback?> goToCurrentLocation() async {
    try {
      final allowed = await _ensurePermission();
      if (!allowed) {
        _setLocationPermission(false);
        return const ClientLocationPickerFeedback(
          title: 'Permiso requerido',
          message:
              'Activa el permiso de ubicaci\u00f3n para usar esta opci\u00f3n.',
          isError: false,
        );
      }

      _setLocationPermission(true);
      final current = await _currentLatLng();
      selectedPosition = current;
      notifyListeners();
      await resolveAddress(current);
      return null;
    } catch (_) {
      return const ClientLocationPickerFeedback(
        title: 'Ubicaci\u00f3n no disponible',
        message: 'No se pudo obtener la ubicaci\u00f3n actual.',
        isError: true,
      );
    }
  }

  Future<void> selectPosition(LatLng position) async {
    selectedPosition = position;
    notifyListeners();
    await resolveAddress(position);
  }

  Future<void> resolveAddress(LatLng position) async {
    isResolvingAddress = true;
    notifyListeners();

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 5));

      if (placemarks.isEmpty) {
        _setSelectedAddress(selectedAddressFallback);
        return;
      }

      final place = placemarks.first;
      final parts = [
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.country,
      ].where((value) => value != null && value.trim().isNotEmpty).toList();

      _setSelectedAddress(
        parts.isNotEmpty ? parts.join(', ') : selectedAddressFallback,
      );
    } catch (_) {
      _setSelectedAddress(selectedAddressFallback);
    } finally {
      isResolvingAddress = false;
      notifyListeners();
    }
  }

  Future<void> _loadCurrentLocationAsInitialPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setPosition(fallbackPosition);
        return;
      }

      final allowed = await _ensurePermission();
      if (!allowed) {
        _setLocationPermission(false);
        _setPosition(fallbackPosition);
        return;
      }

      _setLocationPermission(true);
      _setPosition(await _currentLatLng());
    } catch (_) {
      _setPosition(fallbackPosition);
    }
  }

  Future<bool> _ensurePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }

  Future<LatLng> _currentLatLng() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 5),
      ),
    );

    return LatLng(position.latitude, position.longitude);
  }

  void _setPosition(LatLng position) {
    initialPosition = position;
    selectedPosition = position;
    isLoading = false;
    notifyListeners();
    resolveAddress(position);
  }

  void _setLocationPermission(bool value) {
    hasLocationPermission = value;
    notifyListeners();
  }

  void _setSelectedAddress(String value) {
    selectedAddress = value;
    notifyListeners();
  }
}
