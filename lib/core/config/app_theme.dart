import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'beacon_colors.dart';
import 'design_tokens.dart';

class AppTheme {
  AppTheme._();

  static Color _textOnColor(Color color) {
    return color.computeLuminance() > 0.4
        ? const Color(0xFF1A1A2E)
        : const Color(0xFFFFFFFF);
  }

  // ── Dark Theme ──────────────────────────────────────────────
  static ThemeData dark({
    Color accent = AppColors.blockLime,
    Color sidebarBase = AppColors.sidebarBg,
    Color cardBase = AppColors.surfaceDark,
  }) {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme);
    final onAccent = _textOnColor(accent);
    final bc = BeaconColors.derive(
      sidebarBase: sidebarBase,
      isDark: true,
      cardBase: cardBase,
    );

    return base.copyWith(
      scaffoldBackgroundColor: bc.cardBackground,
      colorScheme: ColorScheme.dark(
        surface: bc.cardSurface,
        onSurface: AppColors.textPrimaryDark,
        primary: accent,
        onPrimary: onAccent,
        secondary: AppColors.blockViolet,
        onSecondary: AppColors.textOnViolet,
        error: AppColors.error,
        onError: Colors.white,
        outline: bc.cardBorder,
        surfaceContainerHighest: bc.cardSurfaceMid,
      ),
      textTheme: textTheme.apply(
        bodyColor: AppColors.textPrimaryDark,
        displayColor: AppColors.textPrimaryDark,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.xl),
        ),
        color: bc.cardSurface,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bc.cardSurfaceMid,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(AppRadius.md),
          borderSide: BorderSide(color: accent, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.mutedDark, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.mutedDark, fontSize: 14),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: bc.cardSurfaceMid,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(AppRadius.md),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: onAccent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(AppRadius.full),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimaryDark,
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(AppRadius.full),
          ),
          side: BorderSide(color: bc.cardBorder, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      dividerTheme: DividerThemeData(
        thickness: 1,
        color: bc.cardBorder.withValues(alpha: 0.5),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: bc.cardBackground,
        foregroundColor: AppColors.textPrimaryDark,
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.lg),
        ),
        elevation: 8,
        color: bc.cardSurface,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.x2l),
        ),
        backgroundColor: bc.cardSurface,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: AppRadius.x2l),
        ),
        backgroundColor: bc.cardSurface,
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),
      extensions: [bc],
    );
  }

  // ── Light Theme ─────────────────────────────────────────────
  static ThemeData light({
    Color accent = AppColors.blockLime,
    Color sidebarBase = AppColors.sidebarBg,
  }) {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme);
    final onAccent = _textOnColor(accent);
    final bc = BeaconColors.derive(
      sidebarBase: sidebarBase,
      isDark: false,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: ColorScheme.light(
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        primary: accent,
        onPrimary: onAccent,
        secondary: AppColors.blockViolet,
        onSecondary: AppColors.textOnViolet,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.borderLight,
        surfaceContainerHighest: AppColors.surfaceMidLight,
      ),
      textTheme: textTheme.apply(
        bodyColor: AppColors.textPrimaryLight,
        displayColor: AppColors.textPrimaryLight,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.xl),
        ),
        color: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMidLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(AppRadius.md),
          borderSide: BorderSide(color: accent, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.mutedLight, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.mutedLight, fontSize: 14),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceMidLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(AppRadius.md),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: onAccent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(AppRadius.full),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimaryLight,
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(AppRadius.full),
          ),
          side: const BorderSide(color: AppColors.borderLight, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.blockViolet,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      dividerTheme: DividerThemeData(
        thickness: 1,
        color: AppColors.borderLight.withValues(alpha: 0.6),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textPrimaryLight,
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.lg),
        ),
        elevation: 8,
        color: AppColors.surfaceLight,
        shadowColor: Colors.black.withValues(alpha: 0.12),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.x2l),
        ),
        backgroundColor: AppColors.surfaceLight,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: AppRadius.x2l),
        ),
        backgroundColor: AppColors.surfaceLight,
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),
      extensions: [bc],
    );
  }
}
