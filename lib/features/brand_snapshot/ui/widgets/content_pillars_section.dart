import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../shared/widgets/app_card.dart';

class ContentPillarsSection extends StatelessWidget {
  const ContentPillarsSection({super.key, required this.pillars});
  final List<Map<String, dynamic>> pillars;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return AppCard(
      variant: AppCardVariant.feature,
      blockColor: AppColors.blockViolet,
      headerTitle: 'Content Pillars',
      child: pillars.isEmpty
          ? _buildEmpty(context, mutedColor)
          : Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: pillars.map((p) {
                final name = p['name'] as String? ?? '';
                final colorHex = p['color'] as String?;
                final bgColor = colorHex != null
                    ? _parseHex(colorHex)
                    : AppColors.blockViolet;
                final textOnBg = bgColor.computeLuminance() > 0.5
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFFFFFFFF);

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.all(AppRadius.full),
                  ),
                  child: Text(
                    name,
                    style: TextStyle(
                      color: textOnBg,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  static Color _parseHex(String hex) {
    final clean = hex.replaceFirst('#', '');
    if (clean.length == 6 && RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(clean)) {
      return Color(int.parse('FF$clean', radix: 16));
    }
    return AppColors.blockViolet;
  }

  Widget _buildEmpty(BuildContext context, Color mutedColor) {
    return Row(
      children: [
        Text(
          'No content pillars added yet.',
          style: AppFonts.inter(fontSize: 14, color: mutedColor)
              .copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(width: AppSpacing.sm),
        TextButton(
          onPressed: () => context.go('/app/voice'),
          child: Text(
            'Add',
            style: AppFonts.inter(fontSize: 14, color: mutedColor),
          ),
        ),
      ],
    );
  }
}
