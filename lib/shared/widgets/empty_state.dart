import 'package:flutter/material.dart';

import '../../core/config/design_tokens.dart';
import '../../core/config/app_fonts.dart';
import 'app_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.blockColor,
    required this.icon,
    required this.headline,
    required this.supportingText,
    this.ctaLabel,
    this.onCtaPressed,
  });

  final Color blockColor;
  final IconData icon;
  final String headline;
  final String supportingText;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    final iconColor = blockColor.computeLuminance() > 0.5
        ? const Color(0xFF1A1A1A)
        : const Color(0xFFFFFFFF);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Block panel
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: blockColor,
                borderRadius: BorderRadius.all(AppRadius.md),
              ),
              child: Center(
                child: Icon(icon, size: 48, color: iconColor),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Headline
            Text(
              headline,
              style: AppFonts.clashDisplay(
                fontSize: 28,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            // Supporting text
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                supportingText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: mutedColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (ctaLabel != null && onCtaPressed != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: ctaLabel,
                onPressed: onCtaPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
