import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../models/platform_preset.dart';
import 'preview_thumbnail.dart';

class PlatformCard extends StatelessWidget {
  const PlatformCard({
    super.key,
    required this.preset,
    required this.onDownload,
    required this.onEdit,
    this.isGenerating = false,
  });

  final PlatformPreset preset;
  final VoidCallback onDownload;
  final VoidCallback onEdit;
  final bool isGenerating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    // Aspect ratio preview
    final aspectRatio = preset.width / preset.height;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.all(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Live preview thumbnail
          GestureDetector(
            onTap: onEdit,
            child: AspectRatio(
              aspectRatio: aspectRatio.clamp(0.5, 3.0),
              child: PreviewThumbnail(preset: preset),
            ),
          ),
          // Info + buttons
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  preset.variant,
                  style: AppFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  preset.displaySize,
                  style: AppFonts.inter(fontSize: 12, color: mutedColor),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Edit',
                        icon: LucideIcons.pencil,
                        variant: AppButtonVariant.secondary,
                        onPressed: onEdit,
                        isFullWidth: true,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: AppButton(
                        label: 'Download',
                        icon: Icons.download,
                        variant: AppButtonVariant.secondary,
                        isLoading: isGenerating,
                        onPressed: isGenerating ? null : onDownload,
                        isFullWidth: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
