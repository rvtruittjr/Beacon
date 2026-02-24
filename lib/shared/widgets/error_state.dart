import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/config/design_tokens.dart';
import '../../core/config/app_fonts.dart';
import 'app_button.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Coral block panel
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.blockCoral,
                borderRadius: BorderRadius.all(AppRadius.md),
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.alertTriangle,
                  size: 48,
                  color: AppColors.textOnCoral,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Something went wrong',
              style: AppFonts.clashDisplay(
                fontSize: 28,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: mutedColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Try again',
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
