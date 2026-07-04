import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BudgetraColors {
  static const primary = Color(0xFF12B981);
  static const primaryStrong = Color(0xFF0F9F6E);
  static const primarySoft = Color(0xFFD8F8EA);

  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);
  static const success = Color(0xFF10B981);

  static const lightBg = Color(0xFFF5F7FB);
  static const lightFg = Color(0xFF0F172A);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightMuted = Color(0xFFEEF2F7);
  static const lightMutedFg = Color(0xFF64748B);
  static const lightBorder = Color(0xFFD7E1EC);
  static const lightSurfaceLow = Color(0xFFF8FBFD);

  static const darkBg = Color(0xFF0B1326);
  static const darkFg = Color(0xFFDAE2FD);
  static const darkCard = Color(0xFF1E293B);
  static const darkMuted = Color(0xFF162234);
  static const darkMutedFg = Color(0xFF94A3B8);
  static const darkBorder = Color(0xFF213045);
  static const darkSurfaceLow = Color(0xFF101928);
}

ThemeData budgetraTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: BudgetraColors.primary,
      onPrimary: Colors.white,
      primaryContainer: BudgetraColors.primarySoft,
      onPrimaryContainer: BudgetraColors.primaryStrong,
      secondary: BudgetraColors.primaryStrong,
      error: BudgetraColors.error,
      surface: BudgetraColors.lightBg,
      onSurface: BudgetraColors.lightFg,
      surfaceContainerLow: BudgetraColors.lightSurfaceLow,
      surfaceContainer: BudgetraColors.lightCard,
      surfaceContainerHigh: BudgetraColors.lightMuted,
      outline: BudgetraColors.lightBorder,
      outlineVariant: BudgetraColors.lightBorder.withValues(alpha: 0.5),
    ),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.03,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.01,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.05,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: BudgetraColors.lightCard,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: BudgetraColors.lightSurfaceLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: BudgetraColors.lightBorder.withValues(alpha: 0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: BudgetraColors.lightBorder.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: BudgetraColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BudgetraColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: BudgetraColors.lightCard,
      foregroundColor: BudgetraColors.lightFg,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: BudgetraColors.lightFg,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: BudgetraColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      selectedColor: BudgetraColors.primarySoft,
      backgroundColor: BudgetraColors.lightMuted,
      labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );
}
