import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/extensions/datetime_extensions.dart';
import '../../../brands/models/brand_model.dart';
import '../../../brands/ui/edit_brand_dialog.dart';

class SnapshotHeader extends StatelessWidget {
  const SnapshotHeader({
    super.key,
    required this.brand,
    this.onExportPdf,
  });
  final BrandModel brand;
  final VoidCallback? onExportPdf;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.sidebarBg,
        borderRadius: BorderRadius.all(AppRadius.xl),
      ),
      child: Row(
        children: [
          // Brand info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand.name,
                  style: AppFonts.clashDisplay(
                    fontSize: 36,
                    color: AppColors.sidebarText,
                  ),
                ),
                if (brand.description != null &&
                    brand.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      brand.description!,
                      style: AppFonts.inter(
                        fontSize: 14,
                        color: AppColors.sidebarMuted,
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Last updated ${brand.createdAt.timeAgo()}',
                  style: AppFonts.inter(
                    fontSize: 12,
                    color: AppColors.sidebarMuted,
                  ),
                ),
              ],
            ),
          ),
          AppButton(
            label: null,
            icon: LucideIcons.pencil,
            variant: AppButtonVariant.icon,
            onPressed: () => EditBrandDialog.show(context, brand),
          ),
          if (onExportPdf != null) ...[
            const SizedBox(width: AppSpacing.xs),
            AppButton(
              label: null,
              icon: LucideIcons.fileText,
              variant: AppButtonVariant.icon,
              onPressed: onExportPdf,
            ),
          ],
          const SizedBox(width: AppSpacing.xs),
          AppButton(
            label: 'Share',
            icon: LucideIcons.share2,
            onPressed: () => context.go('/app/sharing'),
          ),
        ],
      ),
    );
  }
}
