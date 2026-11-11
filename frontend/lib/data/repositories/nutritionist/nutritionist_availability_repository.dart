import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:emprendedor/data/models/nutritionist/nutritionist_availability_model.dart';

class NutritionistAvailabilityRepository {
  NutritionistAvailabilityRepository();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String collectionName = 'nutritionist_availability';

  CollectionReference<Map<String, dynamic>> get _availabilityRef =>
      _firestore.collection(collectionName);

  Future<NutritionistAvailabilityModel?> getAvailability(
    String nutritionistUserId,
  ) async {
    final doc = await _availabilityRef
        .doc(nutritionistUserId)
        .get()
        .timeout(const Duration(seconds: 10));
    if (!doc.exists) return null;
    return NutritionistAvailabilityModel.fromFirestore(doc);
  }

  Stream<NutritionistAvailabilityModel?> watchAvailability(
    String nutritionistUserId,
  ) {
    return _availabilityRef.doc(nutritionistUserId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return NutritionistAvailabilityModel.fromFirestore(doc);
    });
  }

  Future<void> saveAvailability(NutritionistAvailabilityModel availability) {
    return _availabilityRef
        .doc(availability.nutritionistUserId)
        .set(availability.toFirestore(), SetOptions(merge: true))
        .timeout(const Duration(seconds: 12));
  }
}
