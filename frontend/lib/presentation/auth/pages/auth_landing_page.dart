import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/auth/pages/login_page.dart';
import 'package:emprendedor/presentation/auth/pages/register_page.dart';
import 'package:emprendedor/presentation/shared/widgets/nutrigo_logo_mark.dart';

class AuthLandingPage extends StatelessWidget {
  const AuthLandingPage({super.key});

  void _goToLogin(BuildContext context) {
    AppNavigator.push(context, const LoginPage());
  }

  void _goToAdminLogin(BuildContext context) {
    AppNavigator.push(context, const LoginPage(adminOnly: true));
  }

  void _goToRegister(BuildContext context) {
    AppNavigator.push(context, const RegisterPage());
  }

  @override
  Widget build(BuildContext context) {
    return AuthEntryView(
      onLogin: () => _goToLogin(context),
      onRegister: () => _goToRegister(context),
      onAdminAccess: () => _goToAdminLogin(context),
    );
  }
}

class AuthEntryView extends StatelessWidget {
  const AuthEntryView({
    super.key,
    required this.onLogin,
    required this.onRegister,
    required this.onAdminAccess,
  });

  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final VoidCallback onAdminAccess;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: RoleTheme.brandPrimary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: RoleTheme.brandPrimary,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final heroHeight = constraints.maxHeight * 0.43;

            return Stack(
              children: [
                const _AuthHeroBackground(),
                Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  height: heroHeight,
                  child: const SafeArea(bottom: false, child: _AuthTopHero()),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: heroHeight - 34.h,
                  bottom: 0,
                  child: _AuthBottomSheet(
                    onLogin: onLogin,
                    onRegister: onRegister,
                    onAdminAccess: onAdminAccess,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AuthHeroBackground extends StatelessWidget {
  const _AuthHeroBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            RoleTheme.brandPrimary,
            RoleTheme.brandSecondary,
            RoleTheme.brandSoft,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

class _AuthTopHero extends StatelessWidget {
  const _AuthTopHero();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 310.h;
        final topPadding = compact ? 70.h : 96.h;
        final titleSize = compact ? 32.sp : 38.sp;
        final subtitleSize = compact ? 19.sp : 22.sp;

        return Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(color: RoleTheme.brandPrimary),
                child: Image.asset(
                  'assets/branding/auth_hero.png',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0.86, -0.28),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      RoleTheme.brandPrimary.withValues(alpha: 0.94),
                      RoleTheme.brandPrimary.withValues(alpha: 0.82),
                      RoleTheme.brandSecondary.withValues(alpha: 0.42),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.34, 0.68, 1.0],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(26.w, topPadding, 58.w, 18.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    RoleTheme.brandName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: titleSize,
                      letterSpacing: -1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 10.r,
                          offset: Offset(0, 3.h),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Mercado saludable\ny servicios profesionales',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.88),
                      fontSize: subtitleSize,
                      fontWeight: FontWeight.w800,
                      height: 1.12,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AuthBottomSheet extends StatelessWidget {
  const _AuthBottomSheet({
    required this.onLogin,
    required this.onRegister,
    required this.onAdminAccess,
  });

  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final VoidCallback onAdminAccess;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 470.h;
        final iconSize = compact ? 48.w : 58.w;
        final logoSize = compact ? 42.w : 52.w;
        final buttonHeight = compact ? 48.h : 54.h;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(24.w, compact ? 22.h : 30.h, 24.w, 12.h),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(44.r)),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: Center(child: NutriGoLogoMark(size: logoSize)),
                ),
                SizedBox(height: compact ? 10.h : 14.h),
                Text(
                  'Bienvenido',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                    fontSize: compact ? 28.sp : null,
                    letterSpacing: -0.8,
                  ),
                ),
                SizedBox(height: compact ? 4.h : 8.h),
                Text(
                  'Compra, vende y agenda con profesionales\nverificados en un solo lugar.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    fontSize: compact ? 14.sp : null,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: compact ? 16.h : 22.h),
                FilledButton.icon(
                  onPressed: onLogin,
                  icon: Icon(Icons.login_rounded, size: 26.sp),
                  label: const Text('Iniciar sesión'),
                  style: FilledButton.styleFrom(
                    minimumSize: Size.fromHeight(buttonHeight),
                  ),
                ),
                SizedBox(height: 10.h),
                OutlinedButton.icon(
                  onPressed: onRegister,
                  icon: Icon(
                    Icons.person_rounded,
                    color: RoleTheme.iconColorFor(Icons.person_rounded),
                    size: 24.sp,
                  ),
                  label: const Text('Crear cuenta'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.fromHeight(buttonHeight),
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: colorScheme.primary, width: 1.5.w),
                  ),
                ),
                SizedBox(height: compact ? 16.h : 20.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AuthBenefitColumn(
                      compact: compact,
                      icon: Icons.shopping_basket_outlined,
                      label: 'Productos\nsaludables',
                      accent: colorScheme.primary,
                    ),
                    _AuthBenefitDivider(
                      colorScheme: colorScheme,
                      compact: compact,
                    ),
                    _AuthBenefitColumn(
                      compact: compact,
                      icon: Icons.calendar_month_rounded,
                      label: 'Citas con\nnutricionistas',
                      accent: colorScheme.tertiary,
                    ),
                    _AuthBenefitDivider(
                      colorScheme: colorScheme,
                      compact: compact,
                    ),
                    _AuthBenefitColumn(
                      compact: compact,
                      icon: Icons.verified_user_outlined,
                      label: 'Negocios\nvalidados',
                      accent: colorScheme.primary,
                    ),
                  ],
                ),
                SizedBox(height: compact ? 10.h : 16.h),
                Divider(color: colorScheme.outlineVariant),
                TextButton.icon(
                  onPressed: onAdminAccess,
                  icon: Icon(
                    Icons.verified_user_outlined,
                    color: RoleTheme.iconColorFor(Icons.verified_user_outlined),
                    size: 22.sp,
                  ),
                  label: const Text('Ingreso administrativo'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AuthBenefitColumn extends StatelessWidget {
  const _AuthBenefitColumn({
    required this.compact,
    required this.icon,
    required this.label,
    required this.accent,
  });

  final bool compact;
  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.13),
            ),
            child: Padding(
              padding: EdgeInsets.all(compact ? 8.r : 10.r),
              child: Icon(icon, color: accent, size: compact ? 20.sp : 24.sp),
            ),
          ),
          SizedBox(height: compact ? 6.h : 8.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 11.sp : null,
              height: 1.16,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthBenefitDivider extends StatelessWidget {
  const _AuthBenefitDivider({required this.colorScheme, required this.compact});

  final ColorScheme colorScheme;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.w,
      height: compact ? 58.h : 72.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      color: colorScheme.outlineVariant,
    );
  }
}
