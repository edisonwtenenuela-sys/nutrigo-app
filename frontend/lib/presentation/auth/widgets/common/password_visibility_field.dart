import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class PasswordVisibilityField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?) validator;
  final RolePalette palette;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const PasswordVisibilityField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    required this.palette,
    required this.enabled,
    this.onChanged,
  });

  @override
  State<PasswordVisibilityField> createState() =>
      _PasswordVisibilityFieldState();
}

class _PasswordVisibilityFieldState extends State<PasswordVisibilityField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() => _obscureText = !_obscureText);
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final radius = BorderRadius.circular(17.r);

    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _obscureText,
      maxLines: 1,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      enableSuggestions: false,
      autocorrect: false,
      cursorColor: palette.primary,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: palette.text,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w800,
          color: palette.mutedText,
        ),
        prefixIcon: Icon(
          widget.icon,
          color: RoleTheme.iconColorFor(
            widget.icon,
            fallback: palette.primary,
          ),
          size: 20.sp,
        ),
        prefixIconConstraints: BoxConstraints(
          minWidth: 46.w,
        ),
        suffixIcon: IconButton(
          onPressed: widget.enabled ? _toggleVisibility : null,
          tooltip: _obscureText
              ? 'Mostrar contraseña'
              : 'Ocultar contraseña',
          icon: Icon(
            _obscureText
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            color: palette.mutedText,
            size: 20.sp,
          ),
        ),
        filled: true,
        fillColor: palette.surface.withValues(alpha: 0.82),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 15.h,
        ),
        border: OutlineInputBorder(
          borderRadius: radius,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: palette.primary.withValues(alpha: 0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: palette.primary,
            width: 1.5.w,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: palette.primary.withValues(alpha: 0.08),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: RoleTheme.iconDanger,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: RoleTheme.iconDanger,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}