import 'package:flutter/material.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class AppTheme {
  static ThemeData build() {
    const seedColor = RoleTheme.brandPrimary;
    const scaffoldBackground = RoleTheme.brandBackground;

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ).copyWith(
          primary: RoleTheme.brandPrimary,
          secondary: RoleTheme.brandSecondary,
          surface: RoleTheme.brandSurface,
          onSurface: RoleTheme.brandText,
          surfaceContainerHighest: RoleTheme.brandSurfaceTint,
          outlineVariant: RoleTheme.brandBorder,
        );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      iconTheme: const IconThemeData(color: RoleTheme.iconInfo, size: 22),
      primaryIconTheme: const IconThemeData(
        color: RoleTheme.iconInfo,
        size: 22,
      ),
      dividerTheme: DividerThemeData(
        color: RoleTheme.brandBorder.withValues(alpha: 0.70),
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: RoleTheme.iconInfo,
        textColor: RoleTheme.brandText,
        subtitleTextStyle: const TextStyle(
          color: RoleTheme.brandMutedText,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: RoleTheme.brandSurface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: RoleTheme.brandSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: RoleTheme.brandSurface,
        disabledColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.55,
        ),
        selectedColor: RoleTheme.brandSurfaceTint,
        secondarySelectedColor: RoleTheme.brandSoft.withValues(alpha: 0.34),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        labelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
        shape: StadiumBorder(
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.75),
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: RoleTheme.brandSurface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: RoleTheme.brandPrimary,
          backgroundColor: RoleTheme.brandSurfaceTint,
          disabledForegroundColor: RoleTheme.brandPrimary.withValues(
            alpha: 0.42,
          ),
          disabledBackgroundColor: RoleTheme.brandPrimary.withValues(
            alpha: 0.10,
          ),
          side: BorderSide(
            color: RoleTheme.brandPrimary.withValues(alpha: 0.16),
          ),
          elevation: 0,
          minimumSize: const Size.fromHeight(44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: RoleTheme.brandPrimary,
          backgroundColor: RoleTheme.brandPrimary.withValues(alpha: 0.035),
          side: BorderSide(
            color: RoleTheme.brandPrimary.withValues(alpha: 0.16),
          ),
          minimumSize: const Size.fromHeight(44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: RoleTheme.brandPrimary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: RoleTheme.brandText,
        contentTextStyle: const TextStyle(
          color: RoleTheme.brandSurface,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: RoleTheme.brandPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}









