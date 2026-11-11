import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class RegistrationFormLoadingView extends StatefulWidget {
  final RolePalette palette;
  final IconData icon;
  final String eyebrow;
  final String title;
  final String message;
  final List<String> steps;

  const RegistrationFormLoadingView({
    super.key,
    required this.palette,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.message,
    required this.steps,
  });

  @override
  State<RegistrationFormLoadingView> createState() =>
      _RegistrationFormLoadingViewState();
}

class _RegistrationFormLoadingViewState
    extends State<RegistrationFormLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.035),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;

    return Scaffold(
      backgroundColor: RoleTheme.brandBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  RoleTheme.brandBadgeBackground,
                  RoleTheme.brandBackground,
                  Colors.white,
                ],
              ),
            ),
          ),
          Positioned(
            top: -86.h,
            right: -58.w,
            child: _SoftOrb(
              size: 214.w,
              color: palette.primary.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            bottom: -78.h,
            left: -62.w,
            child: _SoftOrb(
              size: 198.w,
              color: palette.secondary.withValues(alpha: 0.10),
            ),
          ),
          Positioned(
            top: 122.h,
            left: -44.w,
            child: _SoftOrb(
              size: 126.w,
              color: palette.primary.withValues(alpha: 0.10),
            ),
          ),
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 22.w),
                    padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 20.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(34.r),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          RoleTheme.brandSurface,
                          RoleTheme.brandBadgeBackground.withValues(
                            alpha: 0.74,
                          ),
                          RoleTheme.brandSurface,
                        ],
                      ),
                      border: Border.all(
                        color: RoleTheme.brandBorder.withValues(alpha: 0.70),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: palette.primary.withValues(alpha: 0.10),
                          blurRadius: 34.r,
                          offset: Offset(0, 20.h),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _RoleIconBadge(palette: palette, icon: widget.icon),
                        SizedBox(height: 18.h),
                        Text(
                          widget.eyebrow,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: palette.primary,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: RoleTheme.brandText,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w900,
                            height: 1.03,
                            letterSpacing: -0.7,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          widget.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: RoleTheme.brandMutedText,
                            fontSize: 12.8.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: 22.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999.r),
                          child: LinearProgressIndicator(
                            minHeight: 7.h,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.70,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              palette.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: 18.h),
                        _LoadingSteps(palette: palette, steps: widget.steps),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleIconBadge extends StatelessWidget {
  final RolePalette palette;
  final IconData icon;

  const _RoleIconBadge({
    required this.palette,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72.w,
      height: 72.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.primary, palette.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.18),
            blurRadius: 24.r,
            offset: Offset(0, 13.h),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 34.sp),
    );
  }
}

class _LoadingSteps extends StatelessWidget {
  final RolePalette palette;
  final List<String> steps;

  const _LoadingSteps({
    required this.palette,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.w,
      runSpacing: 8.h,
      children: steps
          .map(
            (step) => Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: palette.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: palette.primary.withValues(alpha: 0.14),
            ),
          ),
          child: Text(
            step,
            style: TextStyle(
              color: RoleTheme.brandText,
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      )
          .toList(),
    );
  }
}

class _SoftOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftOrb({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}