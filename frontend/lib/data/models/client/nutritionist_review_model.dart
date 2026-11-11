import 'package:cloud_firestore/cloud_firestore.dart';

class NutritionistReviewModel {
  final String? id;
  final String appointmentId;
  final String clientUserId;
  final String clientName;
  final String? clientProfileImageUrl;
  final String nutritionistUserId;
  final String nutritionistName;
  final int rating;
  final String? comment;
  final Timestamp createdAt;

  NutritionistReviewModel({
    this.id,
    required this.appointmentId,
    required this.clientUserId,
    required this.clientName,
    this.clientProfileImageUrl,
    required this.nutritionistUserId,
    required this.nutritionistName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory NutritionistReviewModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final createdAt = data['createdAt'];

    return NutritionistReviewModel(
      id: doc.id,
      appointmentId: data['appointmentId']?.toString() ?? '',
      clientUserId: data['clientUserId']?.toString() ?? '',
      clientName: data['clientName']?.toString() ?? '',
      clientProfileImageUrl: data['clientProfileImageUrl']?.toString(),
      nutritionistUserId: data['nutritionistUserId']?.toString() ?? '',
      nutritionistName: data['nutritionistName']?.toString() ?? '',
      rating: (data['rating'] as num?)?.toInt() ?? 0,
      comment: data['comment']?.toString(),
      createdAt: createdAt is Timestamp
          ? createdAt
          : Timestamp.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'clientUserId': clientUserId,
      'clientName': clientName,
      if (clientProfileImageUrl != null)
        'clientProfileImageUrl': clientProfileImageUrl,
      'nutritionistUserId': nutritionistUserId,
      'nutritionistName': nutritionistName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }

  NutritionistReviewModel copyWith({
    String? id,
    String? appointmentId,
    String? clientUserId,
    String? clientName,
    String? clientProfileImageUrl,
    String? nutritionistUserId,
    String? nutritionistName,
    int? rating,
    String? comment,
    Timestamp? createdAt,
  }) {
    return NutritionistReviewModel(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      clientUserId: clientUserId ?? this.clientUserId,
      clientName: clientName ?? this.clientName,
      clientProfileImageUrl:
          clientProfileImageUrl ?? this.clientProfileImageUrl,
      nutritionistUserId: nutritionistUserId ?? this.nutritionistUserId,
      nutritionistName: nutritionistName ?? this.nutritionistName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
