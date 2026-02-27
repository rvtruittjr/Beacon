import 'package:flutter/material.dart';

import '../../core/config/design_tokens.dart';
import '../../core/config/app_fonts.dart';

enum AppCardVariant { standard, feature }

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.standard,
    this.blockColor,
    this.headerTitle,
    this.padding,
  });

  final Widget child;
  final AppCardVariant variant;
  final Color? blockColor;
  final String? headerTitle;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = theme.colorScheme.surface;
    final borderColor = theme.colorScheme.outline;

    if (variant == AppCardVariant.feature && blockColor != null) {
      return _buildFeatureCard(surfaceColor, borderColor, isDark);
    }

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.all(AppRadius.xl),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );
  }

  Widget _buildFeatureCard(
    Color surfaceColor,
    Color borderColor,
    bool isDark,
  ) {
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.all(AppRadius.xl),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: isDark ? null : AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Clean header row
          if (headerTitle != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                0,
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: blockColor,
                      borderRadius: BorderRadius.all(AppRadius.xs),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    headerTitle!,
                    style: AppFonts.clashDisplay(
                      fontSize: 18,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          // Card body
          Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ],
      ),
    );
  }
}
