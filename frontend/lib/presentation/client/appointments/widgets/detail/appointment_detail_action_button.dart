import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:emprendedor/presentation/shared/widgets/buttons/app_action_button.dart';

class AppointmentDetailActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const AppointmentDetailActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: ClientActionButton(
        label: label,
        icon: icon,
        color: color,
        height: 48.h,
        fontSize: 13.sp,
        radius: 16.r,
        onPressed: onPressed,
      ),
    );
  }
}








