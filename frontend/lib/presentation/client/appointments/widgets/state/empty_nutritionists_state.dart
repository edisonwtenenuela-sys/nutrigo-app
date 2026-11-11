import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class EmptyNutritionistsState extends StatelessWidget {
  const EmptyNutritionistsState({super.key});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;
    final healthColor = RoleTheme.iconColorFor(
      Icons.health_and_safety_outlined,
      fallback: RoleTheme.iconHealth,
    );

    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 28.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 56.h,
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
                      border: Border.all(
                        color: healthColor.withValues(alpha: 0.10),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: healthColor.withValues(alpha: 0.035),
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
                                healthColor.withValues(alpha: 0.13),
                                RoleTheme.iconValidation.withValues(
                                  alpha: 0.10,
                                ),
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
                                  color: healthColor.withValues(alpha: 0.10),
                                ),
                              ),
                              child: Icon(
                                Icons.health_and_safety_outlined,
                                size: 34.sp,
                                color: healthColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 18.h),
                        Text(
                          'Sin nutricionistas disponibles',
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
                          'Cuando existan profesionales verificados, podrás seleccionar uno y agendar tu consulta.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: palette.mutedText,
                            height: 1.35,
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}