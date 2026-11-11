import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus { pending, confirmed, completed, cancelled, noShow }

enum AppointmentPaymentStatus { pending, paid, failed, refunded }

enum ConsultationMode { virtual, presencial }

extension AppointmentStatusX on AppointmentStatus {
  String get value {
    switch (this) {
      case AppointmentStatus.pending:
        return 'pending';
      case AppointmentStatus.confirmed:
        return 'confirmed';
      case AppointmentStatus.completed:
        return 'completed';
      case AppointmentStatus.cancelled:
        return 'cancelled';
      case AppointmentStatus.noShow:
        return 'noShow';
    }
  }

  String get label {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Pendiente';
      case AppointmentStatus.confirmed:
        return 'Confirmada';
      case AppointmentStatus.completed:
        return 'Completada';
      case AppointmentStatus.cancelled:
        return 'Cancelada';
      case AppointmentStatus.noShow:
        return 'No asistió';
    }
  }
}

extension AppointmentPaymentStatusX on AppointmentPaymentStatus {
  String get value {
    switch (this) {
      case AppointmentPaymentStatus.pending:
        return 'pending';
      case AppointmentPaymentStatus.paid:
        return 'paid';
      case AppointmentPaymentStatus.failed:
        return 'failed';
      case AppointmentPaymentStatus.refunded:
        return 'refunded';
    }
  }

  String get label {
    switch (this) {
      case AppointmentPaymentStatus.pending:
        return 'Pendiente';
      case AppointmentPaymentStatus.paid:
        return 'Pagado';
      case AppointmentPaymentStatus.failed:
        return 'Fallido';
      case AppointmentPaymentStatus.refunded:
        return 'Reembolsado';
    }
  }
}

extension ConsultationModeX on ConsultationMode {
  String get value {
    switch (this) {
      case ConsultationMode.virtual:
        return 'virtual';
      case ConsultationMode.presencial:
        return 'presencial';
    }
  }

  String get label {
    switch (this) {
      case ConsultationMode.virtual:
        return 'Virtual';
      case ConsultationMode.presencial:
        return 'Presencial';
    }
  }
}

AppointmentStatus stringToAppointmentStatus(String? value) {
  switch (value) {
    case 'confirmed':
      return AppointmentStatus.confirmed;
    case 'completed':
      return AppointmentStatus.completed;
    case 'cancelled':
      return AppointmentStatus.cancelled;
    case 'noShow':
      return AppointmentStatus.noShow;
    case 'pending':
    default:
      return AppointmentStatus.pending;
  }
}

AppointmentPaymentStatus stringToAppointmentPaymentStatus(String? value) {
  switch (value) {
    case 'paid':
      return AppointmentPaymentStatus.paid;
    case 'failed':
      return AppointmentPaymentStatus.failed;
    case 'refunded':
      return AppointmentPaymentStatus.refunded;
    case 'pending':
    default:
      return AppointmentPaymentStatus.pending;
  }
}

ConsultationMode stringToConsultationMode(String? value) {
  switch (value) {
    case 'presencial':
      return ConsultationMode.presencial;
    case 'virtual':
    default:
      return ConsultationMode.virtual;
  }
}

class AppointmentModel {
  final String? id;

  final String clientUserId;
  final String clientName;
  final String? clientProfileImageUrl;

  final String nutritionistUserId;
  final String nutritionistName;
  final String? nutritionistProfileImageUrl;

  final Timestamp appointmentDate;
  final ConsultationMode consultationMode;

  final String? meetingLink;
  final String? meetingLinkStatus;
  final String? contactPhone;
  final String? clientContactPhone;
  final String? appointmentAddress;
  final double? appointmentLatitude;
  final double? appointmentLongitude;
  final String? appointmentInstructions;

  final double amount;
  final String currency;
  final String? paymentIntentId;
  final AppointmentPaymentStatus paymentStatus;

  final String? notes;
  final String? recommendations;

  final AppointmentStatus status;

  final bool isReviewed;
  final int? reviewRating;
  final String? reviewComment;

  final Timestamp createdAt;
  final Timestamp? updatedAt;

  AppointmentModel({
    this.id,
    required this.clientUserId,
    required this.clientName,
    this.clientProfileImageUrl,
    required this.nutritionistUserId,
    required this.nutritionistName,
    this.nutritionistProfileImageUrl,
    required this.appointmentDate,
    this.consultationMode = ConsultationMode.virtual,
    this.meetingLink,
    this.meetingLinkStatus,
    this.contactPhone,
    this.clientContactPhone,
    this.appointmentAddress,
    this.appointmentLatitude,
    this.appointmentLongitude,
    this.appointmentInstructions,
    required this.amount,
    this.currency = 'usd',
    this.paymentIntentId,
    this.paymentStatus = AppointmentPaymentStatus.pending,
    this.notes,
    this.recommendations,
    this.status = AppointmentStatus.pending,
    this.isReviewed = false,
    this.reviewRating,
    this.reviewComment,
    required this.createdAt,
    this.updatedAt,
  });

  bool get hasPassed {
    return appointmentDate.toDate().isBefore(DateTime.now());
  }

  bool get isVirtual {
    return consultationMode == ConsultationMode.virtual;
  }

  bool get isPresencial {
    return consultationMode == ConsultationMode.presencial;
  }

  bool get hasLocation {
    return appointmentLatitude != null && appointmentLongitude != null;
  }

  bool get hasMeetingLink {
    return meetingLink != null && meetingLink!.trim().isNotEmpty;
  }

  bool get isMeetingLinkPending {
    return isVirtual &&
        !hasMeetingLink &&
        (meetingLinkStatus == 'pending_generation' ||
            meetingLinkStatus == 'generating');
  }

  bool get needsManualMeetingLink {
    return isVirtual &&
        !hasMeetingLink &&
        meetingLinkStatus == 'manual_required';
  }

  bool get hasContactPhone {
    return contactPhone != null && contactPhone!.trim().isNotEmpty;
  }

  bool get hasClientContactPhone {
    return clientContactPhone != null && clientContactPhone!.trim().isNotEmpty;
  }

  bool get canClientReview {
    return status == AppointmentStatus.completed && hasPassed && !isReviewed;
  }

  bool get cannotReview {
    return status == AppointmentStatus.cancelled ||
        status == AppointmentStatus.noShow ||
        status == AppointmentStatus.pending ||
        status == AppointmentStatus.confirmed ||
        isReviewed;
  }

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppointmentModel.fromMap(data, doc.id);
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> data, String id) {
    return AppointmentModel(
      id: id,
      clientUserId: data['clientUserId']?.toString() ?? '',
      clientName: data['clientName']?.toString() ?? '',
      clientProfileImageUrl: data['clientProfileImageUrl']?.toString(),
      nutritionistUserId: data['nutritionistUserId']?.toString() ?? '',
      nutritionistName: data['nutritionistName']?.toString() ?? '',
      nutritionistProfileImageUrl: data['nutritionistProfileImageUrl']
          ?.toString(),
      appointmentDate: data['appointmentDate'] is Timestamp
          ? data['appointmentDate'] as Timestamp
          : Timestamp.now(),
      consultationMode: stringToConsultationMode(
        data['consultationMode']?.toString(),
      ),
      meetingLink: data['meetingLink']?.toString(),
      meetingLinkStatus: data['meetingLinkStatus']?.toString(),
      contactPhone: data['contactPhone']?.toString(),
      clientContactPhone: data['clientContactPhone']?.toString(),
      appointmentAddress: data['appointmentAddress']?.toString(),
      appointmentLatitude: (data['appointmentLatitude'] as num?)?.toDouble(),
      appointmentLongitude: (data['appointmentLongitude'] as num?)?.toDouble(),
      appointmentInstructions: data['appointmentInstructions']?.toString(),
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency']?.toString() ?? 'usd',
      paymentIntentId: data['paymentIntentId']?.toString(),
      paymentStatus: stringToAppointmentPaymentStatus(
        data['paymentStatus']?.toString(),
      ),
      notes: data['notes']?.toString(),
      recommendations: data['recommendations']?.toString(),
      status: stringToAppointmentStatus(data['status']?.toString()),
      isReviewed: data['isReviewed'] as bool? ?? false,
      reviewRating: (data['reviewRating'] as num?)?.toInt(),
      reviewComment: data['reviewComment']?.toString(),
      createdAt: data['createdAt'] is Timestamp
          ? data['createdAt'] as Timestamp
          : Timestamp.now(),
      updatedAt: data['updatedAt'] is Timestamp
          ? data['updatedAt'] as Timestamp
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientUserId': clientUserId,
      'clientName': clientName,
      'clientProfileImageUrl': clientProfileImageUrl,
      'nutritionistUserId': nutritionistUserId,
      'nutritionistName': nutritionistName,
      'nutritionistProfileImageUrl': nutritionistProfileImageUrl,
      'appointmentDate': appointmentDate,
      'consultationMode': consultationMode.value,
      'meetingLink': meetingLink,
      'meetingLinkStatus': meetingLinkStatus,
      'contactPhone': contactPhone,
      'clientContactPhone': clientContactPhone,
      'appointmentAddress': appointmentAddress,
      'appointmentLatitude': appointmentLatitude,
      'appointmentLongitude': appointmentLongitude,
      'appointmentInstructions': appointmentInstructions,
      'amount': amount,
      'currency': currency,
      'paymentIntentId': paymentIntentId,
      'paymentStatus': paymentStatus.value,
      'notes': notes,
      'recommendations': recommendations,
      'status': status.value,
      'isReviewed': isReviewed,
      'reviewRating': reviewRating,
      'reviewComment': reviewComment,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Map<String, dynamic> toFirestore() {
    return toMap();
  }

  AppointmentModel copyWith({
    String? id,
    String? clientUserId,
    String? clientName,
    String? clientProfileImageUrl,
    String? nutritionistUserId,
    String? nutritionistName,
    String? nutritionistProfileImageUrl,
    Timestamp? appointmentDate,
    ConsultationMode? consultationMode,
    String? meetingLink,
    String? meetingLinkStatus,
    String? contactPhone,
    String? clientContactPhone,
    String? appointmentAddress,
    double? appointmentLatitude,
    double? appointmentLongitude,
    String? appointmentInstructions,
    double? amount,
    String? currency,
    String? paymentIntentId,
    AppointmentPaymentStatus? paymentStatus,
    String? notes,
    String? recommendations,
    AppointmentStatus? status,
    bool? isReviewed,
    int? reviewRating,
    String? reviewComment,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      clientUserId: clientUserId ?? this.clientUserId,
      clientName: clientName ?? this.clientName,
      clientProfileImageUrl:
          clientProfileImageUrl ?? this.clientProfileImageUrl,
      nutritionistUserId: nutritionistUserId ?? this.nutritionistUserId,
      nutritionistName: nutritionistName ?? this.nutritionistName,
      nutritionistProfileImageUrl:
          nutritionistProfileImageUrl ?? this.nutritionistProfileImageUrl,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      consultationMode: consultationMode ?? this.consultationMode,
      meetingLink: meetingLink ?? this.meetingLink,
      meetingLinkStatus: meetingLinkStatus ?? this.meetingLinkStatus,
      contactPhone: contactPhone ?? this.contactPhone,
      clientContactPhone: clientContactPhone ?? this.clientContactPhone,
      appointmentAddress: appointmentAddress ?? this.appointmentAddress,
      appointmentLatitude: appointmentLatitude ?? this.appointmentLatitude,
      appointmentLongitude: appointmentLongitude ?? this.appointmentLongitude,
      appointmentInstructions:
          appointmentInstructions ?? this.appointmentInstructions,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      recommendations: recommendations ?? this.recommendations,
      status: status ?? this.status,
      isReviewed: isReviewed ?? this.isReviewed,
      reviewRating: reviewRating ?? this.reviewRating,
      reviewComment: reviewComment ?? this.reviewComment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}








