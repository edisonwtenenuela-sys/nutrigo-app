import 'package:emprendedor/data/repositories/nutritionist/nutritionist_profile_repository.dart';

class AppointmentDetailHeaderController {
  AppointmentDetailHeaderController({NutritionistProfileRepository? repository})
    : _repository = repository ?? NutritionistProfileRepository();

  static final Map<String, String?> _nutritionistImageCache = {};

  final NutritionistProfileRepository _repository;

  String? cachedNutritionistImage(String nutritionistUserId) {
    final key = nutritionistUserId.trim();
    if (!_nutritionistImageCache.containsKey(key)) return null;

    final imageUrl = _nutritionistImageCache[key]?.trim();
    if (imageUrl == null || imageUrl.isEmpty) return null;
    return imageUrl;
  }

  void cacheNutritionistImage(String nutritionistUserId, String? imageUrl) {
    final key = nutritionistUserId.trim();
    if (key.isEmpty) return;

    final cleanImageUrl = imageUrl?.trim();
    _nutritionistImageCache[key] =
        cleanImageUrl == null || cleanImageUrl.isEmpty ? null : cleanImageUrl;
  }

  Future<String?> loadNutritionistImage(String nutritionistUserId) async {
    final key = nutritionistUserId.trim();
    if (_nutritionistImageCache.containsKey(key)) {
      return cachedNutritionistImage(key);
    }

    final profile = await _repository.getNutritionistProfile(key);
    cacheNutritionistImage(key, profile?.profileImageUrl);
    return cachedNutritionistImage(key);
  }
}








