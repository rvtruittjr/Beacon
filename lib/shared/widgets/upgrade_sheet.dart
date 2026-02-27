import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/config/design_tokens.dart';
import '../../core/config/app_fonts.dart';
import 'app_button.dart';

/// Shows a reusable upgrade bottom sheet when free tier limits are hit.
Future<void> showUpgradeSheet(
  BuildContext context, {
  required String feature,
  required String description,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _UpgradeSheetContent(
      feature: feature,
      description: description,
    ),
  );
}

class _UpgradeSheetContent extends StatelessWidget {
  const _UpgradeSheetContent({
    required this.feature,
    required this.description,
  });

  final String feature;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = theme.colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: AppRadius.xl),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline,
              borderRadius: BorderRadius.all(AppRadius.full),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Coral header block
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.blockCoral,
              borderRadius: BorderRadius.all(AppRadius.lg),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.sparkles,
                  color: AppColors.textOnCoral,
                  size: 28,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Unlock $feature',
                    style: AppFonts.clashDisplay(
                      fontSize: 22,
                      color: AppColors.textOnCoral,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              description,
              style: AppFonts.inter(
                fontSize: 15,
                color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Upgrade button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: AppButton(
              label: 'Upgrade to Pro — \$12/month',
              icon: LucideIcons.sparkles,
              isFullWidth: true,
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to subscription screen
                // GoRouter.of(context).go('/app/settings/subscription');
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Maybe later
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Maybe later',
              style: AppFonts.inter(
                fontSize: 14,
                color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).viewPadding.bottom + AppSpacing.lg,
          ),
        ],
      ),
    );
  }
}
