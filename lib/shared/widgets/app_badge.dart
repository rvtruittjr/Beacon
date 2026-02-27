import 'package:flutter/material.dart';

import '../../core/config/design_tokens.dart';

enum AppBadgeVariant { standard, success, warning, error, platform }

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.standard,
    this.platformName,
  });

  final String label;
  final AppBadgeVariant variant;
  final String? platformName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final (bgColor, fgColor) = _resolveColors(context, isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(AppRadius.full),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fgColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  (Color bg, Color fg) _resolveColors(BuildContext context, bool isDark) {
    if (variant == AppBadgeVariant.platform && platformName != null) {
      return _platformColors(platformName!);
    }

    return switch (variant) {
      AppBadgeVariant.standard => (
          Theme.of(context).colorScheme.surfaceContainerHighest,
          isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
        ),
      AppBadgeVariant.success => (
          AppColors.success.withValues(alpha: 0.15),
          AppColors.success,
        ),
      AppBadgeVariant.warning => (
          AppColors.warning.withValues(alpha: 0.15),
          AppColors.warning,
        ),
      AppBadgeVariant.error => (
          AppColors.error.withValues(alpha: 0.15),
          AppColors.error,
        ),
      AppBadgeVariant.platform => (
          AppColors.surfaceMidDark,
          AppColors.textPrimaryDark,
        ),
    };
  }

  static (Color bg, Color fg) _platformColors(String platform) {
    return switch (platform.toLowerCase()) {
      'youtube' => (const Color(0xFFFF0000), const Color(0xFFFFFFFF)),
      'tiktok' => (const Color(0xFF1A1A1A), const Color(0xFFFFFFFF)),
      'instagram' => (const Color(0xFFE1306C), const Color(0xFFFFFFFF)),
      'twitter' || 'x' => (const Color(0xFF1DA1F2), const Color(0xFFFFFFFF)),
      _ => (const Color(0xFF6C63FF), const Color(0xFFFFFFFF)),
    };
  }
}
