import 'package:flutter/material.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class AuthScreenBackground extends StatelessWidget {
  final Widget child;
  final RolePalette palette;

  const AuthScreenBackground({
    super.key,
    required this.child,
    this.palette = RoleTheme.client,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.52, 1.0],
          colors: [
            Colors.white,
            palette.background,
            RoleTheme.brandBadgeBackground,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -90,
            top: -80,
            width: 260,
            height: 260,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    palette.primary.withValues(alpha: 0.12),
                    palette.primary.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -100,
            top: 110,
            width: 280,
            height: 280,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    palette.secondary.withValues(alpha: 0.12),
                    palette.secondary.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -120,
            right: -120,
            bottom: -150,
            height: 340,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                  colors: [
                    palette.accent.withValues(alpha: 0.20),
                    palette.primary.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}