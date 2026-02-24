import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/extensions/datetime_extensions.dart';
import '../../../brands/models/brand_model.dart';

class SnapshotHeader extends StatelessWidget {
  const SnapshotHeader({super.key, required this.brand});
  final BrandModel brand;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.blockYellow,
        borderRadius: BorderRadius.all(AppRadius.lg),
      ),
      child: Stack(
        children: [
          // Brand info — bottom left
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                brand.name,
                style: AppFonts.clashDisplay(
                  fontSize: 48,
                  color: AppColors.textOnYellow,
                ),
              ),
              if (brand.description != null &&
                  brand.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    brand.description!,
                    style: AppFonts.inter(
                      fontSize: 16,
                      color: AppColors.textOnYellow.withValues(alpha: 0.7),
                    ),
                  ),
                ),
            ],
          ),
          // Top right — Share button + timestamp
          Positioned(
            top: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppButton(
                  label: 'Share',
                  icon: LucideIcons.share2,
                  onPressed: () => context.go('/app/sharing'),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Last updated ${brand.createdAt.timeAgo()}',
                  style: AppFonts.inter(
                    fontSize: 12,
                    color: AppColors.textOnYellow.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
