import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../shared/widgets/app_card.dart';

class LogoVariationsSection extends StatelessWidget {
  const LogoVariationsSection({super.key, required this.logos});
  final List<Map<String, dynamic>> logos;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return AppCard(
      variant: AppCardVariant.feature,
      blockColor: AppColors.blockViolet,
      headerTitle: 'Logos',
      child: logos.isEmpty
          ? _buildEmpty(context, mutedColor)
          : _buildGrid(context, mutedColor),
    );
  }

  Widget _buildGrid(BuildContext context, Color mutedColor) {
    // Use Wrap instead of GridView to work correctly inside IntrinsicHeight
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: logos.map((logo) {
        return SizedBox(
          width: 140,
          height: 140,
          child: _LogoCard(
            name: logo['name'] as String? ?? 'Logo',
            url: logo['file_url'] as String? ?? '',
            mutedColor: mutedColor,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmpty(BuildContext context, Color mutedColor) {
    return Row(
      children: [
        Text(
          'No logos added yet.',
          style: AppFonts.inter(fontSize: 14, color: mutedColor)
              .copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(width: AppSpacing.sm),
        TextButton(
          onPressed: () => context.go('/app/brand-kit'),
          child: Text(
            'Add',
            style: AppFonts.inter(fontSize: 14, color: mutedColor),
          ),
        ),
      ],
    );
  }
}

class _LogoCard extends StatelessWidget {
  const _LogoCard({
    required this.name,
    required this.url,
    required this.mutedColor,
  });

  final String name;
  final String url;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLightbox(context),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(AppRadius.md),
          border: Border.all(
            color: mutedColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: url.isNotEmpty
                    ? Image.network(
                        url,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.image_outlined,
                          size: 32,
                          color: mutedColor,
                        ),
                      )
                    : Icon(
                        Icons.image_outlined,
                        size: 32,
                        color: mutedColor,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.xs,
                left: AppSpacing.xs,
                right: AppSpacing.xs,
              ),
              child: Text(
                name,
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLightbox(BuildContext context) {
    if (url.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(ctx).pop(),
          child: InteractiveViewer(
            child: Image.network(
              url,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
