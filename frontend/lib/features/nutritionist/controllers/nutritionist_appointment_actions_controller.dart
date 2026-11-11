import 'package:emprendedor/core/services/external_url_launcher_service.dart';
import 'package:emprendedor/data/models/client/appointment_model.dart';

class NutritionistAppointmentActionsController {
  const NutritionistAppointmentActionsController({
    required this.appointment,
    ExternalUrlLauncherService launcher = const ExternalUrlLauncherService(),
  }) : _launcher = launcher;

  final AppointmentModel appointment;
  final ExternalUrlLauncherService _launcher;

  bool get canOpenMeetingLink =>
      appointment.isVirtual && appointment.hasMeetingLink;

  bool get isMeetingLinkPending =>
      appointment.isVirtual && appointment.isMeetingLinkPending;

  bool get needsManualMeetingLink =>
      appointment.isVirtual && appointment.needsManualMeetingLink;

  bool get canOpenMaps {
    return appointment.isPresencial && mapsUrl != null;
  }

  bool get canOpenWhatsApp => whatsappUrl != null;

  String? get meetingUrl {
    final link = appointment.meetingLink?.trim();
    return link == null || link.isEmpty ? null : link;
  }

  String? get mapsUrl {
    final address = appointment.appointmentAddress?.trim();
    if (address == null || address.isEmpty) return null;

    return 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
  }

  String? get whatsappUrl {
    final phone = appointment.clientContactPhone?.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    if (phone == null || phone.isEmpty) return null;

    return 'https://wa.me/$phone';
  }

  Future<bool> openMeetingLink() => _openUrl(meetingUrl);

  Future<bool> openMaps() => _openUrl(mapsUrl);

  Future<bool> openWhatsApp() => _openUrl(whatsappUrl);

  Future<bool> _openUrl(String? url) => _launcher.openExternalUrl(url);
}








