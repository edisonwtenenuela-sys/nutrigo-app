import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

Future<String?> showRejectionReasonDialog(
    BuildContext context, {
      required String title,
      required String subject,
      String? hintText,
    }) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => RejectionReasonDialog(
      title: title,
      subject: subject,
      hintText: hintText,
    ),
  );
}

class RejectionReasonDialog extends StatefulWidget {
  final String title;
  final String subject;
  final String? hintText;

  const RejectionReasonDialog({
    super.key,
    required this.title,
    required this.subject,
    this.hintText,
  });

  @override
  State<RejectionReasonDialog> createState() => _RejectionReasonDialogState();
}

class _RejectionReasonDialogState extends State<RejectionReasonDialog> {
  final TextEditingController _controller = TextEditingController();

  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final reason = _controller.text.trim();

    if (reason.length < 8) {
      setState(() {
        _errorText = 'Indica un motivo claro de al menos 8 caracteres.';
      });
      return;
    }

    Navigator.of(context).pop(reason);
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.r),
      borderSide: BorderSide(color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.admin;

    return AlertDialog(
      backgroundColor: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22.r),
      ),
      title: Text(
        widget.title,
        style: TextStyle(
          color: palette.text,
          fontSize: 18.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Este motivo será enviado a ${widget.subject} para que pueda corregir y reenviar la solicitud.',
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 12.2.sp,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _controller,
            autofocus: true,
            minLines: 3,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(
              color: palette.text,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              labelText: 'Motivo del rechazo',
              hintText: widget.hintText ??
                  'Ej: Falta completar el RUC o el documento no coincide.',
              errorText: _errorText,
              filled: true,
              fillColor: palette.background.withValues(alpha: 0.72),
              labelStyle: TextStyle(
                color: palette.mutedText,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
              hintStyle: TextStyle(
                color: palette.mutedText,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
              border: _inputBorder(
                palette.primary.withValues(alpha: 0.14),
              ),
              enabledBorder: _inputBorder(
                palette.primary.withValues(alpha: 0.14),
              ),
              focusedBorder: _inputBorder(
                palette.primary,
              ),
              errorBorder: _inputBorder(
                RoleTheme.iconDanger,
              ),
              focusedErrorBorder: _inputBorder(
                RoleTheme.iconDanger,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.send_rounded),
          label: const Text('Rechazar'),
        ),
      ],
    );
  }
}