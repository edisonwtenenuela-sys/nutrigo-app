import 'package:emprendedor/core/services/external_url_launcher_service.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';

class AppointmentDetailController {
  const AppointmentDetailController({
    required this.appointment,
    ExternalUrlLauncherService launcher = const ExternalUrlLauncherService(),
  }) : _launcher = launcher;

  static const Duration _virtualAccessWindow = Duration(minutes: 10);
  static const Duration _virtualGraceWindow = Duration(hours: 2);

  final AppointmentModel appointment;
  final ExternalUrlLauncherService _launcher;

  bool get canJoinVirtualAppointment {
    return appointment.isVirtual &&
        appointment.status == AppointmentStatus.confirmed &&
        appointment.hasMeetingLink &&
        isWithinVirtualAccessWindow;
  }

  bool get isWithinVirtualAccessWindow {
    final startsAt = appointment.appointmentDate.toDate();
    final now = DateTime.now();
    final opensAt = startsAt.subtract(_virtualAccessWindow);
    final closesAt = startsAt.add(_virtualGraceWindow);

    return now.isAfter(opensAt) && now.isBefore(closesAt);
  }

  bool get canOpenMaps {
    return appointment.hasLocation ||
        (appointment.appointmentAddress?.trim().isNotEmpty ?? false);
  }

  String get virtualAccessMessage {
    if (appointment.hasMeetingLink) {
      if (appointment.status != AppointmentStatus.confirmed) {
        return 'El enlace estará disponible cuando el nutricionista confirme la cita.';
      }

      if (!isWithinVirtualAccessWindow) {
        return 'El enlace ya está listo. Podrás ingresar 10 minutos antes de la cita.';
      }

      return 'La cita fue confirmada. Ya puedes ingresar a la videollamada.';
    }

    if (appointment.isMeetingLinkPending) {
      return 'Estamos generando el enlace de videollamada para esta cita.';
    }

    if (appointment.needsManualMeetingLink) {
      return 'No se pudo generar el Meet automático. El nutricionista debe revisar la configuración del calendario.';
    }

    return 'El enlace estará disponible cuando se genere.';
  }

  String get virtualActionLabel {
    if (canJoinVirtualAppointment) return 'Unirse a la cita';
    if (appointment.hasMeetingLink) return 'Disponible 10 min antes';
    if (appointment.isMeetingLinkPending) return 'Generando Meet';
    if (appointment.needsManualMeetingLink) return 'Meet pendiente';
    return appointment.status == AppointmentStatus.confirmed
        ? 'Generando Meet'
        : 'Disponible cuando confirme';
  }

  String formatAmount() {
    return '${appointment.amount.toStringAsFixed(2)} ${appointment.currency.toUpperCase()}';
  }

  Future<bool> openMeetingLink() async {
    final link = appointment.meetingLink?.trim();
    if (link == null || link.isEmpty) return false;
    return _openUrl(link);
  }

  Future<bool> openWhatsApp() async {
    final phone = appointment.contactPhone?.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone == null || phone.isEmpty) return false;
    return _openUrl('https://wa.me/$phone');
  }

  Future<bool> openMaps() async {
    final url = mapsUrl;
    if (url == null) return false;
    return _openUrl(url);
  }

  String? get mapsUrl {
    if (appointment.hasLocation) {
      return 'https://www.google.com/maps/search/?api=1&query=${appointment.appointmentLatitude},${appointment.appointmentLongitude}';
    }

    final address = appointment.appointmentAddress?.trim();
    if (address == null || address.isEmpty) return null;

    return 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
  }

  Future<bool> _openUrl(String url) => _launcher.openExternalUrl(url);
}








