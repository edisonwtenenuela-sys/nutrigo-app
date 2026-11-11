import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessReviewModel {
  final String? id;
  final String orderId;
  final String businessUserId;
  final String clientUserId;
  final String clientName;
  final String? clientProfileImageUrl;
  final double rating;
  final String comment;
  final Timestamp? createdAt;

  BusinessReviewModel({
    this.id,
    required this.orderId,
    required this.businessUserId,
    required this.clientUserId,
    this.clientName = '',
    this.clientProfileImageUrl,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  factory BusinessReviewModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return BusinessReviewModel(
      id: doc.id,
      orderId: data['orderId']?.toString() ?? '',
      businessUserId: data['businessUserId']?.toString() ?? '',
      clientUserId: data['clientUserId']?.toString() ?? '',
      clientName: data['clientName']?.toString() ?? '',
      clientProfileImageUrl: data['clientProfileImageUrl']?.toString(),
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      comment: data['comment']?.toString() ?? '',
      createdAt: data['createdAt'] is Timestamp
          ? data['createdAt'] as Timestamp
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'orderId': orderId,
      'businessUserId': businessUserId,
      'clientUserId': clientUserId,
      'clientName': clientName,
      if (clientProfileImageUrl != null)
        'clientProfileImageUrl': clientProfileImageUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  BusinessReviewModel copyWith({
    String? id,
    String? orderId,
    String? businessUserId,
    String? clientUserId,
    String? clientName,
    String? clientProfileImageUrl,
    double? rating,
    String? comment,
    Timestamp? createdAt,
  }) {
    return BusinessReviewModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      businessUserId: businessUserId ?? this.businessUserId,
      clientUserId: clientUserId ?? this.clientUserId,
      clientName: clientName ?? this.clientName,
      clientProfileImageUrl:
          clientProfileImageUrl ?? this.clientProfileImageUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
