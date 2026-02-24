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
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    if (variant == AppCardVariant.feature && blockColor != null) {
      return _buildFeatureCard(surfaceColor, borderColor);
    }

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.all(AppRadius.md),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );
  }

  Widget _buildFeatureCard(Color surfaceColor, Color borderColor) {
    // Determine text color based on block color luminance
    final textOnBlock = blockColor!.computeLuminance() > 0.5
        ? const Color(0xFF1A1A1A)
        : const Color(0xFFFFFFFF);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.all(AppRadius.md),
        border: Border.all(color: borderColor, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Color block header
          Container(
            height: 100,
            color: blockColor,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: headerTitle != null
                ? Text(
                    headerTitle!,
                    style: AppFonts.clashDisplay(
                      fontSize: 24,
                      color: textOnBlock,
                    ),
                  )
                : null,
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
