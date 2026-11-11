import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class PasswordMatchHint extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final RolePalette palette;

  const PasswordMatchHint({
    super.key,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        passwordController,
        confirmPasswordController,
      ]),
      builder: (context, _) {
        final password = passwordController.text;
        final confirmation = confirmPasswordController.text;
        final shouldShow =
            confirmation.isNotEmpty && password != confirmation;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: shouldShow
              ? Padding(
            key: const ValueKey('password-mismatch'),
            padding: EdgeInsets.only(top: 8.h),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 9.h,
              ),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.055),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: RoleTheme.iconColorFor(
                      Icons.error_outline_rounded,
                      fallback: Colors.red,
                    ),
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Las contraseñas no coinciden.',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 11.2.sp,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
              : const SizedBox.shrink(
            key: ValueKey('password-match-empty'),
          ),
        );
      },
    );
  }
}