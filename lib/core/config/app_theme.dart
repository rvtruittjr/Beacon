import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'design_tokens.dart';

class AppTheme {
  AppTheme._();

  // ── Dark Theme ──────────────────────────────────────────────
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: ColorScheme.dark(
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        primary: AppColors.blockViolet,
        onPrimary: AppColors.textOnViolet,
        secondary: AppColors.blockLime,
        onSecondary: AppColors.textOnLime,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.borderDark,
        surfaceContainerHighest: AppColors.surfaceMidDark,
      ),
      textTheme: textTheme.apply(
        bodyColor: AppColors.textPrimaryDark,
        displayColor: AppColors.textPrimaryDark,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.lg),
          side: BorderSide(
            color: AppColors.borderDark.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        color: AppColors.surfaceDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMidDark,
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
          borderSide: const BorderSide(color: AppColors.focusRing, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.mutedDark, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.mutedDark, fontSize: 14),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceMidDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(AppRadius.md),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blockLime,
          foregroundColor: AppColors.textOnLime,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimaryDark,
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(AppRadius.md),
          ),
          side: const BorderSide(color: AppColors.borderDark, width: 1.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textPrimaryDark,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      dividerTheme: DividerThemeData(
        thickness: 1,
        color: AppColors.borderDark.withValues(alpha: 0.5),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.lg),
        ),
        elevation: 8,
        color: AppColors.surfaceDark,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.xl),
        ),
        backgroundColor: AppColors.surfaceDark,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: AppRadius.xl),
        ),
        backgroundColor: AppColors.surfaceDark,
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
      ),
    );
  }

  // ── Light Theme ─────────────────────────────────────────────
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: ColorScheme.light(
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        primary: AppColors.blockViolet,
        onPrimary: AppColors.textOnViolet,
        secondary: AppColors.blockLime,
        onSecondary: AppColors.textOnLime,
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
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.xl),
        ),
        color: AppColors.surfaceLight,
        shadowColor: Colors.black.withValues(alpha: 0.08),
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
          borderSide: const BorderSide(color: AppColors.focusRing, width: 2),
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
          backgroundColor: AppColors.blockLime,
          foregroundColor: AppColors.textOnLime,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimaryLight,
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(AppRadius.md),
          ),
          side: const BorderSide(color: AppColors.borderLight, width: 1.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textPrimaryLight,
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
          borderRadius: BorderRadius.all(AppRadius.xl),
        ),
        backgroundColor: AppColors.surfaceLight,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: AppRadius.xl),
        ),
        backgroundColor: AppColors.surfaceLight,
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
      ),
    );
  }
}
