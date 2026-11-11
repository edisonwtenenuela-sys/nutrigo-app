import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

import 'package:emprendedor/core/utils/ecuador_time_utils.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';

class AppointmentSlotUnavailableException implements Exception {
  const AppointmentSlotUnavailableException([
    this.message = 'Ese horario ya fue tomado. Elige otra hora.',
  ]);

  final String message;

  @override
  String toString() => message;
}

class AppointmentRepository {
  AppointmentRepository();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger('AppointmentRepository');
  final Map<String, String?> _clientProfileImageCache = {};
  final Set<String> _clientProfileImagePersistedAppointments = {};

  static const String collectionName = 'appointments';
  static const String appointmentSlotsCollection = 'appointment_slots';

  CollectionReference<Map<String, dynamic>> get _appointmentsRef =>
      _firestore.collection(collectionName);

  CollectionReference<Map<String, dynamic>> get _appointmentSlotsRef =>
      _firestore.collection(appointmentSlotsCollection);

  Future<DocumentReference<Map<String, dynamic>>> createAppointment(
    AppointmentModel appointment,
  ) async {
    final data = appointment.toFirestore();

    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();

    return _appointmentsRef.add(data);
  }

  Future<DocumentReference<Map<String, dynamic>>>
  createAppointmentIfSlotAvailable(AppointmentModel appointment) async {
    final appointmentRef = _appointmentsRef.doc();
    final slotRef = _appointmentSlotsRef.doc(_slotKeyFor(appointment));
    final data = appointment.toFirestore();

    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore.runTransaction((transaction) async {
      final slotDoc = await transaction.get(slotRef);
      final slotData = slotDoc.data();
      if (slotDoc.exists && slotData?['isActive'] == true) {
        throw const AppointmentSlotUnavailableException();
      }

      transaction.set(appointmentRef, data);
      transaction.set(slotRef, {
        'appointmentId': appointmentRef.id,
        'clientUserId': appointment.clientUserId,
        'nutritionistUserId': appointment.nutritionistUserId,
        'appointmentDate': appointment.appointmentDate,
        'hour': _hourFromTimestamp(appointment.appointmentDate),
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    return appointmentRef;
  }

  Future<Set<String>> getBookedHoursForNutritionist({
    required String nutritionistUserId,
    required DateTime date,
  }) async {
    final dateKey =
        '${date.year.toString().padLeft(4, '0')}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    final slotPrefix = '${nutritionistUserId}_${dateKey}_';

    final snapshot = await _appointmentSlotsRef
        .orderBy(FieldPath.documentId)
        .startAt([slotPrefix])
        .endAt(['$slotPrefix\uf8ff'])
        .get();

    return snapshot.docs
        .where((doc) => doc.data()['isActive'] == true)
        .map((doc) {
          final hour = doc.data()['hour']?.toString().trim();
          if (hour != null && hour.isNotEmpty) return hour;

          final hourKey = doc.id.split('_').last;
          if (hourKey.length != 4) return '';
          return '${hourKey.substring(0, 2)}:${hourKey.substring(2, 4)}';
        })
        .where((hour) => hour.isNotEmpty)
        .toSet();
  }

  Stream<List<AppointmentModel>> getAppointmentsForClient(String clientUserId) {
    return _appointmentsRef
        .where('clientUserId', isEqualTo: clientUserId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => AppointmentModel.fromFirestore(doc))
              .toList();

          list.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

          return list;
        });
  }

  Stream<List<AppointmentModel>> getAppointmentsForNutritionist(
    String nutritionistUserId,
  ) {
    return _appointmentsRef
        .where('nutritionistUserId', isEqualTo: nutritionistUserId)
        .snapshots()
        .asyncMap((snapshot) async {
          final list = snapshot.docs
              .map((doc) => AppointmentModel.fromFirestore(doc))
              .toList();
          final hydratedList = await _hydrateClientProfileImages(list);

          hydratedList.sort(
            (a, b) => a.appointmentDate.compareTo(b.appointmentDate),
          );

          return hydratedList;
        });
  }

  Future<List<AppointmentModel>> _hydrateClientProfileImages(
    List<AppointmentModel> appointments,
  ) async {
    final missingClientIds = appointments
        .where(
          (appointment) =>
              _isBlank(appointment.clientProfileImageUrl) &&
              appointment.clientUserId.trim().isNotEmpty,
        )
        .map((appointment) => appointment.clientUserId.trim())
        .toSet();

    for (final clientUserId in missingClientIds) {
      if (_clientProfileImageCache.containsKey(clientUserId)) continue;

      try {
        final doc = await _firestore
            .collection('clients')
            .doc(clientUserId)
            .get();
        final imageUrl = doc.data()?['profileImageUrl']?.toString().trim();
        _clientProfileImageCache[clientUserId] = _isBlank(imageUrl)
            ? null
            : imageUrl;
      } catch (error, stackTrace) {
        _logger.warning(
          'No se pudo cargar la foto del cliente para la cita.',
          error,
          stackTrace,
        );
        _clientProfileImageCache[clientUserId] = null;
      }
    }

    final hydratedAppointments = <AppointmentModel>[];
    final persistTasks = <Future<void>>[];

    for (final appointment in appointments) {
      if (!_isBlank(appointment.clientProfileImageUrl)) {
        hydratedAppointments.add(appointment);
        continue;
      }

      final imageUrl =
          _clientProfileImageCache[appointment.clientUserId.trim()];
      if (_isBlank(imageUrl)) {
        hydratedAppointments.add(appointment);
        continue;
      }

      hydratedAppointments.add(
        appointment.copyWith(clientProfileImageUrl: imageUrl),
      );

      final appointmentId = appointment.id;
      if (!_isBlank(appointmentId) &&
          !_clientProfileImagePersistedAppointments.contains(appointmentId)) {
        _clientProfileImagePersistedAppointments.add(appointmentId!);
        persistTasks.add(_persistClientProfileImage(appointmentId, imageUrl!));
      }
    }

    if (persistTasks.isNotEmpty) {
      await Future.wait(persistTasks);
    }

    return hydratedAppointments;
  }

  Future<void> _persistClientProfileImage(
    String appointmentId,
    String imageUrl,
  ) async {
    try {
      await _appointmentsRef.doc(appointmentId).set({
        'clientProfileImageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (error, stackTrace) {
      _logger.warning(
        'No se pudo guardar la foto del cliente en la cita antigua.',
        error,
        stackTrace,
      );
    }
  }

  bool _isBlank(String? value) => value == null || value.trim().isEmpty;

  Future<AppointmentModel?> getAppointmentById(String appointmentId) async {
    final doc = await _appointmentsRef.doc(appointmentId).get();

    if (!doc.exists) return null;

    return AppointmentModel.fromFirestore(doc);
  }

  Future<AppointmentModel?> getAppointmentByIdForClient(
    String appointmentId,
    String clientUserId,
  ) async {
    final doc = await _appointmentsRef.doc(appointmentId).get();

    if (!doc.exists) return null;

    final data = doc.data();

    if (data == null || data['clientUserId'] != clientUserId) {
      return null;
    }

    return AppointmentModel.fromFirestore(doc);
  }

  Stream<AppointmentModel?> watchAppointmentByIdForClient(
    String appointmentId,
    String clientUserId,
  ) {
    return _appointmentsRef.doc(appointmentId).snapshots().map((doc) {
      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null || data['clientUserId'] != clientUserId) {
        return null;
      }

      return AppointmentModel.fromFirestore(doc);
    });
  }

  Future<AppointmentModel?> getAppointmentByIdForNutritionist(
    String appointmentId,
    String nutritionistUserId,
  ) async {
    final doc = await _appointmentsRef.doc(appointmentId).get();

    if (!doc.exists) return null;

    final data = doc.data();

    if (data == null || data['nutritionistUserId'] != nutritionistUserId) {
      return null;
    }

    return AppointmentModel.fromFirestore(doc);
  }

  Future<int> countAppointmentsForClient(String clientUserId) async {
    final snapshot = await _appointmentsRef
        .where('clientUserId', isEqualTo: clientUserId)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  Future<int> countAppointmentsForNutritionist(
    String nutritionistUserId,
  ) async {
    final snapshot = await _appointmentsRef
        .where('nutritionistUserId', isEqualTo: nutritionistUserId)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  Future<void> updateAppointmentStatusForNutritionist(
    String appointmentId,
    AppointmentStatus status,
    String nutritionistUserId,
  ) async {
    final docRef = _appointmentsRef.doc(appointmentId);
    final doc = await docRef
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 10));

    if (!doc.exists ||
        doc.data()?['nutritionistUserId'] != nutritionistUserId) {
      throw Exception('No autorizado para actualizar esta cita.');
    }

    await docRef
        .update({
          'status': status.value,
          'statusUpdatedBy': 'nutritionist',
          'updatedAt': FieldValue.serverTimestamp(),
        })
        .timeout(const Duration(seconds: 12));

    if (status == AppointmentStatus.cancelled) {
      await _releaseAppointmentSlot(AppointmentModel.fromFirestore(doc));
    }
  }

  Future<void> markAppointmentAsCompletedForNutritionist(
    String appointmentId,
    String nutritionistUserId,
  ) async {
    await updateAppointmentStatusForNutritionist(
      appointmentId,
      AppointmentStatus.completed,
      nutritionistUserId,
    );
  }

  Future<void> markAppointmentAsNoShowForNutritionist(
    String appointmentId,
    String nutritionistUserId,
  ) async {
    await updateAppointmentStatusForNutritionist(
      appointmentId,
      AppointmentStatus.noShow,
      nutritionistUserId,
    );
  }

  Future<void> updatePaymentStatusForClient(
    String appointmentId,
    AppointmentPaymentStatus paymentStatus,
    String clientUserId, {
    String? paymentIntentId,
  }) async {
    final docRef = _appointmentsRef.doc(appointmentId);
    final doc = await docRef.get();

    if (!doc.exists || doc.data()?['clientUserId'] != clientUserId) {
      throw Exception('No autorizado para actualizar el pago de esta cita.');
    }

    final data = <String, dynamic>{
      'paymentStatus': paymentStatus.value,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (paymentIntentId != null && paymentIntentId.trim().isNotEmpty) {
      data['paymentIntentId'] = paymentIntentId;
    }

    await docRef.update(data);
  }

  Future<void> updateRecommendationsForNutritionist(
    String appointmentId,
    String nutritionistUserId,
    String recommendations,
  ) async {
    final docRef = _appointmentsRef.doc(appointmentId);
    final doc = await docRef.get();

    if (!doc.exists ||
        doc.data()?['nutritionistUserId'] != nutritionistUserId) {
      throw Exception('No autorizado para actualizar recomendaciones.');
    }

    await docRef.update({
      'recommendations': recommendations,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelAppointmentForClient(
    String appointmentId,
    String clientUserId,
  ) async {
    final docRef = _appointmentsRef.doc(appointmentId);
    final doc = await docRef.get();

    if (!doc.exists || doc.data()?['clientUserId'] != clientUserId) {
      throw Exception('No autorizado para cancelar esta cita.');
    }

    await docRef.update({
      'status': AppointmentStatus.cancelled.value,
      'statusUpdatedBy': 'client',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _releaseAppointmentSlot(AppointmentModel.fromFirestore(doc));
  }

  Future<void> _releaseAppointmentSlot(AppointmentModel appointment) async {
    try {
      await _appointmentSlotsRef.doc(_slotKeyFor(appointment)).set({
        'isActive': false,
        'releasedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (error, stackTrace) {
      _logger.warning(
        'No se pudo liberar el horario de la cita.',
        error,
        stackTrace,
      );
    }
  }

  String _slotKeyFor(AppointmentModel appointment) {
    final dateKey = EcuadorTimeUtils.slotDateKeyFromTimestamp(
      appointment.appointmentDate,
    );
    final hourKey = EcuadorTimeUtils.hourLabelFromTimestamp(
      appointment.appointmentDate,
    ).replaceAll(':', '');
    return '${appointment.nutritionistUserId}_${dateKey}_$hourKey';
  }

  String _hourFromTimestamp(Timestamp timestamp) {
    return EcuadorTimeUtils.hourLabelFromTimestamp(timestamp);
  }
}
