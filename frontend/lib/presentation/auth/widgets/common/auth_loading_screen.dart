import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/shared/widgets/nutrigo_logo_mark.dart';

class AuthLoadingScreen extends StatefulWidget {
  const AuthLoadingScreen({super.key});

  @override
  State<AuthLoadingScreen> createState() => _AuthLoadingScreenState();
}

class _AuthLoadingScreenState extends State<AuthLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1350),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = RoleTheme.client;

    return Scaffold(
      backgroundColor: palette.background,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final pulse = Curves.easeInOut.transform(_controller.value);

          return Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      RoleTheme.brandBadgeBackground,
                      palette.background,
                      palette.surface,
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 34.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.scale(
                          scale: 0.96 + (pulse * 0.04),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.r),
                              boxShadow: [
                                BoxShadow(
                                  color: palette.primary.withValues(
                                    alpha: 0.10 + (pulse * 0.05),
                                  ),
                                  blurRadius: 24.r + (pulse * 10.r),
                                  offset: Offset(0, 14.h),
                                ),
                              ],
                            ),
                            child: NutriGoLogoMark(size: 96.w),
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          'Preparando NutriGo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: palette.text,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Validando tu acceso y cargando tu perfil.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: palette.mutedText,
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.32,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: palette.surface,
                            borderRadius: BorderRadius.circular(22.r),
                            border: Border.all(
                              color: palette.primary.withValues(alpha: 0.18),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: palette.primary.withValues(alpha: 0.08),
                                blurRadius: 20.r,
                                offset: Offset(0, 10.h),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 34.w,
                                height: 34.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.w,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    palette.primary,
                                  ),
                                  backgroundColor:
                                  palette.primary.withValues(alpha: 0.10),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sincronizando perfil',
                                      style: TextStyle(
                                        color: palette.text,
                                        fontSize: 12.5.sp,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(height: 3.h),
                                    Text(
                                      'Esto tomará solo unos segundos.',
                                      style: TextStyle(
                                        color: palette.mutedText,
                                        fontSize: 10.5.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                        SizedBox(
                          width: 140.w,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999.r),
                            child: LinearProgressIndicator(
                              minHeight: 5.h,
                              backgroundColor:
                              palette.primary.withValues(alpha: 0.10),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                palette.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}