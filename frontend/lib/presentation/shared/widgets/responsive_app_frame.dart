import 'package:flutter/material.dart';

import 'package:emprendedor/core/theme/role_theme.dart';

class ResponsiveAppFrame extends StatelessWidget {
  const ResponsiveAppFrame({super.key, required this.child});

  final Widget child;

  static const double _tabletBreakpoint = 600;
  static const double _maxAppWidth = 430;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final normalizedChild = MediaQuery(
      data: mediaQuery.copyWith(
        textScaler: mediaQuery.textScaler.clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.15,
        ),
      ),
      child: child,
    );

    if (mediaQuery.size.width < _tabletBreakpoint) {
      return normalizedChild;
    }

    return ColoredBox(
      color: RoleTheme.brandBackground,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxAppWidth),
          child: ClipRect(child: normalizedChild),
        ),
      ),
    );
  }
}








