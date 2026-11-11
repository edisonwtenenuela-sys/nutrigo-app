import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/feedback/app_feedback_level.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

enum AppFeedbackRole { auth, client, entrepreneur, nutritionist, admin }

enum AppFeedbackType { success, error, warning, info }

extension AppFeedbackLevelMapper on AppFeedbackLevel {
  AppFeedbackType toPresentationType() {
    return switch (this) {
      AppFeedbackLevel.success => AppFeedbackType.success,
      AppFeedbackLevel.error => AppFeedbackType.error,
      AppFeedbackLevel.warning => AppFeedbackType.warning,
      AppFeedbackLevel.info => AppFeedbackType.info,
    };
  }
}

RolePalette appFeedbackPalette(AppFeedbackRole role) {
  switch (role) {
    case AppFeedbackRole.client:
      return RoleTheme.client;
    case AppFeedbackRole.entrepreneur:
      return RoleTheme.entrepreneur;
    case AppFeedbackRole.nutritionist:
      return RoleTheme.nutritionist;
    case AppFeedbackRole.admin:
      return RoleTheme.admin;
    case AppFeedbackRole.auth:
      return RoleTheme.client;
  }
}

Future<void> showAppMessage(
    BuildContext context, {
      required String title,
      required String message,
      AppFeedbackRole role = AppFeedbackRole.auth,
      AppFeedbackType type = AppFeedbackType.info,
      String buttonText = 'Aceptar',
      bool barrierDismissible = true,
    }) async {
  if (!context.mounted) return;

  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Mensaje',
    barrierColor: Colors.black.withValues(alpha: 0.32),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return _AppFeedbackDialog(
        title: title,
        message: message,
        role: role,
        type: type,
        primaryText: buttonText,
        onPrimary: () => Navigator.of(dialogContext).pop(),
      );
    },
    transitionBuilder: _dialogTransitionBuilder,
  );
}

void showAppSnackMessage(
    BuildContext context, {
      required String message,
      AppFeedbackRole role = AppFeedbackRole.auth,
      AppFeedbackType type = AppFeedbackType.info,
    }) {
  if (!context.mounted) return;

  final palette = appFeedbackPalette(role);

  final accent = switch (type) {
    AppFeedbackType.success => const Color(0xFF16A34A),
    AppFeedbackType.error => const Color(0xFFEF4444),
    AppFeedbackType.warning => const Color(0xFFF59E0B),
    AppFeedbackType.info => palette.primary,
  };

  final icon = switch (type) {
    AppFeedbackType.success => Icons.check_circle_rounded,
    AppFeedbackType.error => Icons.error_outline_rounded,
    AppFeedbackType.warning => Icons.warning_amber_rounded,
    AppFeedbackType.info => Icons.info_outline_rounded,
  };

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18.sp),
            SizedBox(width: 9.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: accent,
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
}

Future<bool> showAppConfirm(
    BuildContext context, {
      required String title,
      required String message,
      AppFeedbackRole role = AppFeedbackRole.auth,
      AppFeedbackType type = AppFeedbackType.warning,
      String confirmText = 'Aceptar',
      String cancelText = 'Cancelar',
      bool barrierDismissible = true,
    }) async {
  if (!context.mounted) return false;

  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Confirmación',
    barrierColor: Colors.black.withValues(alpha: 0.32),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return _AppFeedbackDialog(
        title: title,
        message: message,
        role: role,
        type: type,
        primaryText: confirmText,
        secondaryText: cancelText,
        onPrimary: () => Navigator.of(dialogContext).pop(true),
        onSecondary: () => Navigator.of(dialogContext).pop(false),
      );
    },
    transitionBuilder: _dialogTransitionBuilder,
  );

  return result ?? false;
}

Widget _dialogTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    ) {
  return FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
    child: ScaleTransition(
      scale: Tween<double>(
        begin: 0.96,
        end: 1,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}

class _AppFeedbackDialog extends StatelessWidget {
  final String title;
  final String message;
  final AppFeedbackRole role;
  final AppFeedbackType type;
  final String primaryText;
  final String? secondaryText;
  final VoidCallback onPrimary;
  final VoidCallback? onSecondary;

  const _AppFeedbackDialog({
    required this.title,
    required this.message,
    required this.role,
    required this.type,
    required this.primaryText,
    required this.onPrimary,
    this.secondaryText,
    this.onSecondary,
  });

  Color _accent(RolePalette palette) {
    switch (type) {
      case AppFeedbackType.success:
      case AppFeedbackType.info:
        return palette.primary;
      case AppFeedbackType.warning:
        return const Color(0xFFF59E0B);
      case AppFeedbackType.error:
        return const Color(0xFFEF4444);
    }
  }

  IconData get _icon {
    switch (type) {
      case AppFeedbackType.success:
        return Icons.check_rounded;
      case AppFeedbackType.error:
        return Icons.close_rounded;
      case AppFeedbackType.warning:
        return Icons.priority_high_rounded;
      case AppFeedbackType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = appFeedbackPalette(role);
    final accent = _accent(palette);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return SafeArea(
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: screenWidth > 390 ? 344.w : screenWidth - 44.w,
            margin: EdgeInsets.symmetric(horizontal: 22.w),
            padding: EdgeInsets.fromLTRB(17.w, 16.h, 17.w, 15.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: accent.withValues(alpha: 0.14)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 22.r,
                  offset: Offset(0, 11.h),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: screenHeight * 0.78),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(_icon, color: accent, size: 26.sp),
                  ),
                  SizedBox(height: 11.h),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: TextStyle(
                      color: palette.text,
                      fontSize: 16.5.sp,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: TextStyle(
                          color: palette.mutedText,
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),
                  if (secondaryText == null)
                    SizedBox(
                      width: double.infinity,
                      height: 41.h,
                      child: ElevatedButton(
                        onPressed: onPrimary,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: palette.primary.withValues(
                            alpha: 0.055,
                          ),
                          foregroundColor: palette.primary,
                          side: BorderSide(
                            color: palette.primary.withValues(alpha: 0.22),
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          textStyle: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            primaryText,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 41.h,
                            child: OutlinedButton(
                              onPressed: onSecondary,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: palette.mutedText,
                                side: BorderSide(
                                  color: palette.mutedText.withValues(
                                    alpha: 0.22,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                textStyle: TextStyle(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  secondaryText!,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: SizedBox(
                            height: 41.h,
                            child: ElevatedButton(
                              onPressed: onPrimary,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent.withValues(
                                  alpha: 0.055,
                                ),
                                foregroundColor: accent,
                                side: BorderSide(
                                  color: accent.withValues(alpha: 0.22),
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                textStyle: TextStyle(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  primaryText,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}








