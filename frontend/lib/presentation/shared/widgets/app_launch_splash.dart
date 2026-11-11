import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

double _responsiveSize(num value, double min, double max) =>
    value.clamp(min, max).toDouble();

class AppLaunchSplash extends StatefulWidget {
  final Widget child;

  const AppLaunchSplash({super.key, required this.child});

  @override
  State<AppLaunchSplash> createState() => _AppLaunchSplashState();
}

class _AppLaunchSplashState extends State<AppLaunchSplash>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _pulseController;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;

  bool _showSplash = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _fade = CurvedAnimation(parent: _introController, curve: Curves.easeOut);

    _scale = Tween<double>(begin: 0.90, end: 1).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOutBack),
    );

    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _introController, curve: Curves.easeOutCubic),
        );

    _introController.forward();

    _timer = Timer(const Duration(milliseconds: 1420), () {
      if (!mounted) return;
      setState(() => _showSplash = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 360),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _showSplash
          ? _SplashView(
              key: const ValueKey('launch-splash'),
              fade: _fade,
              scale: _scale,
              slide: _slide,
              pulseController: _pulseController,
            )
          : widget.child,
    );
  }
}

class _SplashView extends StatelessWidget {
  final Animation<double> fade;
  final Animation<double> scale;
  final Animation<Offset> slide;
  final AnimationController pulseController;

  const _SplashView({
    super.key,
    required this.fade,
    required this.scale,
    required this.slide,
    required this.pulseController,
  });

  static const _launchBackground = RoleTheme.brandPrimary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _launchBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: _launchBackground),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = _responsiveSize(34.w, 18, 48);
                final compactHeight = constraints.maxHeight < 720;

                return SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 430),
                          child: FadeTransition(
                            opacity: fade,
                            child: SlideTransition(
                              position: slide,
                              child: ScaleTransition(
                                scale: scale,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedBuilder(
                                      animation: pulseController,
                                      builder: (context, _) {
                                        final pulse = Curves.easeInOut
                                            .transform(pulseController.value);

                                        return _LaunchPulseMark(
                                          pulse: pulse,
                                          compact: compactHeight,
                                        );
                                      },
                                    ),
                                    SizedBox(
                                      height: compactHeight ? 20.h : 30.h,
                                    ),
                                    Text(
                                      'Preparando NutriGo',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: _responsiveSize(
                                          27.sp,
                                          22,
                                          30,
                                        ),
                                        fontWeight: FontWeight.w900,
                                        height: 1.02,
                                        letterSpacing: -0.8,
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    Text(
                                      'Organizamos tu mercado saludable y servicios profesionales en un solo lugar.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.78,
                                        ),
                                        fontSize: _responsiveSize(
                                          13.2.sp,
                                          12,
                                          15,
                                        ),
                                        fontWeight: FontWeight.w700,
                                        height: 1.35,
                                      ),
                                    ),
                                    SizedBox(
                                      height: compactHeight ? 24.h : 34.h,
                                    ),
                                    const _LaunchProgressBar(),
                                    SizedBox(
                                      height: compactHeight ? 14.h : 18.h,
                                    ),
                                    const Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _TrustPill(
                                          icon: Icons.shield_outlined,
                                          text: 'Saludable',
                                        ),
                                        _TrustPill(
                                          icon: Icons.verified_outlined,
                                          text: 'Confiable',
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: compactHeight ? 34.h : 58.h,
                                    ),
                                    Text(
                                      'NutriGo',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.56,
                                        ),
                                        fontSize: _responsiveSize(
                                          12.sp,
                                          11,
                                          13,
                                        ),
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LaunchPulseMark extends StatelessWidget {
  final double pulse;
  final bool compact;

  const _LaunchPulseMark({required this.pulse, required this.compact});

  @override
  Widget build(BuildContext context) {
    final outerSize = compact ? 112.0 : _responsiveSize(138.w, 112, 150);
    final ringSize = compact ? 104.0 : _responsiveSize(128.w, 104, 140);
    final haloSize = compact ? 92.0 : _responsiveSize(112.w, 92, 122);
    final markSize = compact ? 64.0 : _responsiveSize(74.w, 64, 82);

    return SizedBox(
      width: outerSize,
      height: outerSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: 0.86 + (pulse * 0.18),
            child: Container(
              width: ringSize,
              height: ringSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.16),
                  width: _responsiveSize(1.4.w, 1, 1.8),
                ),
              ),
            ),
          ),
          Transform.scale(
            scale: 0.74 + (pulse * 0.10),
            child: Container(
              width: haloSize,
              height: haloSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Container(
            width: markSize,
            height: markSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: _responsiveSize(30.r, 20, 34),
                  offset: Offset(0, _responsiveSize(16.h, 10, 18)),
                ),
              ],
            ),
            child: Icon(
              Icons.sync_rounded,
              color: RoleTheme.brandPrimary,
              size: _responsiveSize(34.sp, 28, 36),
            ),
          ),
        ],
      ),
    );
  }
}

class _LaunchProgressBar extends StatelessWidget {
  const _LaunchProgressBar();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999.r),
      child: LinearProgressIndicator(
        minHeight: 5.5.h,
        backgroundColor: Colors.white.withValues(alpha: 0.16),
        valueColor: AlwaysStoppedAnimation<Color>(
          Colors.white.withValues(alpha: 0.92),
        ),
      ),
    );
  }
}

class _TrustPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TrustPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _responsiveSize(4.w, 3, 5)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _responsiveSize(10.w, 9, 13),
          vertical: _responsiveSize(6.h, 5, 8),
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: _responsiveSize(13.sp, 12, 15),
              color: Colors.white,
            ),
            SizedBox(width: _responsiveSize(5.w, 4, 7)),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: _responsiveSize(10.7.sp, 10, 12),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
