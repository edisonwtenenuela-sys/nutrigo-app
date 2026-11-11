import 'package:flutter/material.dart';

import 'package:emprendedor/data/models/entrepreneur/profile/social_media_model.dart';

class EditSocialMediaController extends ChangeNotifier {
  EditSocialMediaController({required this.socialMedia})
    : urlController = TextEditingController(text: socialMedia.url);

  final SocialMediaModel socialMedia;
  final TextEditingController urlController;

  String? _urlError;
  String? get urlError => _urlError;

  bool get isEditing => socialMedia.url.trim().isNotEmpty;

  String? validateUrl() {
    final url = urlController.text.trim();
    if (url.isEmpty) return 'Ingresa una URL.';

    final parsed = Uri.tryParse(url);
    if (parsed == null || !parsed.hasScheme || parsed.host.trim().isEmpty) {
      return 'Ingresa una URL valida, por ejemplo https://ejemplo.com';
    }

    return null;
  }

  SocialMediaModel? buildUpdatedModel() {
    final error = validateUrl();
    if (error != null) {
      _setUrlError(error);
      return null;
    }

    _setUrlError(null);
    return socialMedia.copyWith(url: urlController.text.trim());
  }

  void _setUrlError(String? value) {
    if (_urlError == value) return;
    _urlError = value;
    notifyListeners();
  }

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }
}








