import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NutritionistSelectedLocation {
  const NutritionistSelectedLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  final double latitude;
  final double longitude;
  final String address;

  Map<String, dynamic> toMap() => {
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
  };
}

class NutritionistLocationPickerController extends ChangeNotifier {
  NutritionistLocationPickerController({
    double? initialLatitude,
    double? initialLongitude,
  }) : selectedLocation = LatLng(
         initialLatitude ?? -2.170998,
         initialLongitude ?? -79.922359,
       );

  static const defaultAddress = 'Ubicación seleccionada';
  static const loadingAddress = 'Obteniendo dirección...';

  LatLng selectedLocation;
  String selectedAddress = defaultAddress;

  NutritionistSelectedLocation get result => NutritionistSelectedLocation(
    latitude: selectedLocation.latitude,
    longitude: selectedLocation.longitude,
    address: selectedAddress,
  );

  Future<void> selectLocation(LatLng position) async {
    selectedLocation = position;
    selectedAddress = loadingAddress;
    notifyListeners();

    try {
      final places = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (places.isEmpty) {
        _setAddress(defaultAddress);
        return;
      }

      final place = places.first;
      final address = [
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
      ].where((item) => item != null && item.trim().isNotEmpty).join(', ');

      _setAddress(address.isNotEmpty ? address : defaultAddress);
    } catch (_) {
      _setAddress(defaultAddress);
    }
  }

  void _setAddress(String value) {
    selectedAddress = value;
    notifyListeners();
  }
}








