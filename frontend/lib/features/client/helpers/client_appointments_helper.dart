import 'package:emprendedor/data/models/client/appointment_model.dart';

class ClientAppointmentsHelper {
  static int countByStatus(
    List<AppointmentModel> appointments,
    AppointmentStatus status,
  ) {
    return appointments.where((item) => item.status == status).length;
  }
}








