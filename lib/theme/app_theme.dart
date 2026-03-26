import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF78DC77);
  static const Color primaryContainer = Color(0xFF4CAF50);
  static const Color onPrimary = Color(0xFF00390A);

  static const Color secondary = Color(0xFF9ECAFF);
  static const Color tertiary = Color(0xFFFFB870);
  static const Color tertiaryContainer = Color(0xFFE18500);
  static const Color onTertiaryContainer = Color(0xFF4D2B00);

  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);

  static const Color background = Color(0xFF0F0F0F);
  static const Color surface = Color(0xFF131313);
  static const Color surfaceContainerLowest = Color(0xFF0E0E0E);
  static const Color surfaceContainerLow = Color(0xFF1C1B1B);
  static const Color surfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighest = Color(0xFF353534);
  static const Color surfaceBright = Color(0xFF3A3939);
  static const Color surfaceVariant = Color(0xFF353534);

  static const Color onSurface = Color(0xFFE5E2E1);
  static const Color onSurfaceVariant = Color(0xFFBECAB9);
  static const Color outlineVariant = Color(0xFF3F4A3C);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryContainer,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outlineVariant: AppColors.outlineVariant,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.manrope(
          fontSize: 56,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurface,
        ),
        displayMedium: GoogleFonts.manrope(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
        headlineLarge: GoogleFonts.manrope(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
        headlineMedium: GoogleFonts.manrope(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurfaceVariant,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 2.0,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.manrope(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
          ),
        ),
      ),
      useMaterial3: true,
    );
  }
}
