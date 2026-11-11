import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/client/cart/widgets/inputs/cart_input_decoration.dart';

class CartStyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final String label;
  final IconData icon;

  const CartStyledTextField({
    super.key,
    required this.controller,
    required this.enabled,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return TextField(
      controller: controller,
      enabled: enabled,
      style: TextStyle(
        color: palette.text,
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
      ),
      decoration: cartInputDecoration(
        label: label,
        icon: icon,
      ),
    );
  }
}