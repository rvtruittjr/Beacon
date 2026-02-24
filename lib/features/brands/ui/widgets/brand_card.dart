import 'package:flutter/material.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../shared/extensions/datetime_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../models/brand_model.dart';

class BrandCard extends StatefulWidget {
  const BrandCard({
    super.key,
    required this.brand,
    required this.onOpen,
  });

  final BrandModel brand;
  final VoidCallback onOpen;

  @override
  State<BrandCard> createState() => _BrandCardState();
}

class _BrandCardState extends State<BrandCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.all(AppRadius.md),
          border: Border.all(
            color: _isHovered
                ? AppColors.blockViolet.withValues(alpha: 0.5)
                : borderColor,
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Violet block header
            Container(
              height: 100,
              color: AppColors.blockViolet,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                widget.brand.name,
                style: AppFonts.clashDisplay(
                  fontSize: 24,
                  color: AppColors.textOnViolet,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.brand.description != null &&
                      widget.brand.description!.isNotEmpty) ...[
                    Text(
                      widget.brand.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: mutedColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  Text(
                    'Created ${widget.brand.createdAt.toDisplayDate()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: mutedColor,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'Open',
                    onPressed: widget.onOpen,
                    variant: AppButtonVariant.ghost,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
