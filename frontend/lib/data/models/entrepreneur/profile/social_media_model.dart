import 'package:cloud_firestore/cloud_firestore.dart';

enum SocialMediaType { facebook, instagram, whatsapp, website, tiktok }

extension SocialMediaTypeX on SocialMediaType {
  String get value {
    switch (this) {
      case SocialMediaType.facebook:
        return 'facebook';
      case SocialMediaType.instagram:
        return 'instagram';
      case SocialMediaType.whatsapp:
        return 'whatsapp';
      case SocialMediaType.website:
        return 'website';
      case SocialMediaType.tiktok:
        return 'tiktok';
    }
  }

  String get label {
    switch (this) {
      case SocialMediaType.facebook:
        return 'Facebook';
      case SocialMediaType.instagram:
        return 'Instagram';
      case SocialMediaType.whatsapp:
        return 'WhatsApp';
      case SocialMediaType.website:
        return 'Sitio web';
      case SocialMediaType.tiktok:
        return 'TikTok';
    }
  }
}

SocialMediaType stringToSocialMediaType(String? value) {
  final normalized = value?.trim().toLowerCase().replaceAll(
    RegExp(r'[\s_-]+'),
    '',
  );

  switch (normalized) {
    case 'facebook':
    case 'fb':
      return SocialMediaType.facebook;
    case 'instagram':
    case 'ig':
      return SocialMediaType.instagram;
    case 'whatsapp':
    case 'wa':
      return SocialMediaType.whatsapp;
    case 'website':
    case 'web':
    case 'sitio':
    case 'sitioweb':
      return SocialMediaType.website;
    case 'tiktok':
    case 'tik tok':
      return SocialMediaType.tiktok;
    default:
      return SocialMediaType.website;
  }
}

class SocialMediaModel {
  final String? id;
  final SocialMediaType type;
  final String url;
  final String userId;

  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  SocialMediaModel({
    this.id,
    required this.type,
    required this.url,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory SocialMediaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return SocialMediaModel(
      id: doc.id,
      type: stringToSocialMediaType(data['type']?.toString()),
      url: data['url']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      createdAt: data['createdAt'] is Timestamp ? data['createdAt'] : null,
      updatedAt: data['updatedAt'] is Timestamp ? data['updatedAt'] : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.value,
      'url': url,
      'userId': userId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  SocialMediaModel copyWith({
    String? id,
    SocialMediaType? type,
    String? url,
    String? userId,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return SocialMediaModel(
      id: id ?? this.id,
      type: type ?? this.type,
      url: url ?? this.url,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
