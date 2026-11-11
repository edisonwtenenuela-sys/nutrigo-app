import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/shared/widgets/buttons/app_action_button.dart';

class ClientProductsEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final String? actionLabel;
  final VoidCallback? onAction;

  const ClientProductsEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 28.h),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 52.h,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(18.w, 22.h, 18.w, 18.h),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: color.withValues(alpha: 0.12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.035),
                        blurRadius: 22.r,
                        offset: Offset(0, 10.h),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 104.w,
                        height: 104.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withValues(alpha: 0.13),
                              color.withValues(alpha: 0.06),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 66.w,
                            height: 66.w,
                            decoration: BoxDecoration(
                              color: palette.surface,
                              borderRadius: BorderRadius.circular(22.r),
                              border: Border.all(
                                color: color.withValues(alpha: 0.10),
                              ),
                            ),
                            child: Icon(icon, size: 34.sp, color: color),
                          ),
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: palette.text,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: palette.mutedText,
                          height: 1.35,
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (actionLabel != null && onAction != null) ...[
                        SizedBox(height: 20.h),
                        ClientActionButton(
                          label: actionLabel!,
                          icon: Icons.refresh_rounded,
                          height: 46.h,
                          fontSize: 13.sp,
                          color: color,
                          onPressed: onAction,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
