import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_badge.dart';

class TypographySection extends StatelessWidget {
  const TypographySection({super.key, required this.fonts});
  final List<Map<String, dynamic>> fonts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return AppCard(
      variant: AppCardVariant.feature,
      blockColor: AppColors.blockViolet,
      headerTitle: 'Typography',
      child: fonts.isEmpty
          ? _buildEmpty(context, mutedColor)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < fonts.length; i++) ...[
                  _FontEntry(
                    font: fonts[i],
                    textColor: textColor,
                    mutedColor: mutedColor,
                  ),
                  if (i < fonts.length - 1) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Divider(color: mutedColor.withValues(alpha: 0.2)),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              ],
            ),
    );
  }

  Widget _buildEmpty(BuildContext context, Color mutedColor) {
    return Row(
      children: [
        Text(
          'No fonts added yet.',
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

class _FontEntry extends StatelessWidget {
  const _FontEntry({
    required this.font,
    required this.textColor,
    required this.mutedColor,
  });

  final Map<String, dynamic> font;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final family = font['family'] as String? ?? 'Unknown';
    final label = font['label'] as String? ?? 'Body';
    final source = font['source'] as String?;

    // Try to load via GoogleFonts if it's a Google Font
    TextStyle familyStyle;
    try {
      if (source == 'google' || source == null) {
        familyStyle = GoogleFonts.getFont(family, fontSize: 24, color: textColor);
      } else {
        familyStyle = TextStyle(
          fontFamily: family,
          fontSize: 24,
          color: textColor,
        );
      }
    } catch (_) {
      familyStyle = TextStyle(
        fontFamily: family,
        fontSize: 24,
        color: textColor,
      );
    }

    TextStyle sampleStyle;
    try {
      if (source == 'google' || source == null) {
        sampleStyle = GoogleFonts.getFont(family, fontSize: 16, color: mutedColor);
      } else {
        sampleStyle = TextStyle(
          fontFamily: family,
          fontSize: 16,
          color: mutedColor,
        );
      }
    } catch (_) {
      sampleStyle = TextStyle(
        fontFamily: family,
        fontSize: 16,
        color: mutedColor,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(family, style: familyStyle),
            ),
            AppBadge(label: label),
          ],
        ),
        const SizedBox(height: 4),
        Text('The quick brown fox', style: sampleStyle),
      ],
    );
  }
}
