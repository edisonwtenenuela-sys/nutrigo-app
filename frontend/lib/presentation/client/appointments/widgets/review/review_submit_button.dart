import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/presentation/shared/widgets/buttons/app_action_button.dart';

class ReviewSubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const ReviewSubmitButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ClientActionButton(
      label: 'Enviar valoración',
      loadingLabel: 'Guardando...',
      icon: Icons.send_rounded,
      height: 46.h,
      fontSize: 13.sp,
      isLoading: isLoading,
      onPressed: onPressed,
    );
  }
}