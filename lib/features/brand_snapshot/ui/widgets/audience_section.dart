import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_badge.dart';

class AudienceSection extends StatelessWidget {
  const AudienceSection({super.key, required this.audience});
  final Map<String, dynamic>? audience;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return AppCard(
      variant: AppCardVariant.feature,
      blockColor: AppColors.blockLime,
      headerTitle: 'Audience',
      child: audience == null
          ? _buildEmpty(context, mutedColor)
          : _buildContent(textColor, mutedColor),
    );
  }

  Widget _buildContent(Color textColor, Color mutedColor) {
    final personaName = audience!['persona_name'] as String?;
    final personaSummary = audience!['persona_summary'] as String?;
    final ageMin = audience!['age_range_min'] as int?;
    final ageMax = audience!['age_range_max'] as int?;
    final locations = _toStringList(audience!['locations']);
    final interests = _toStringList(audience!['interests']);

    final chips = <String>[
      if (ageMin != null && ageMax != null) '$ageMin–$ageMax years',
      ...locations,
      ...interests.take(3),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (personaName != null && personaName.isNotEmpty)
          Text(
            personaName,
            style: AppFonts.clashDisplay(
              fontSize: 20,
              color: textColor,
            ),
          ),
        if (personaSummary != null && personaSummary.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            personaSummary,
            style: AppFonts.inter(fontSize: 14, color: mutedColor),
          ),
        ],
        if (chips.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: chips
                .map((c) => AppBadge(label: c))
                .toList(),
          ),
        ],
      ],
    );
  }

  List<String> _toStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  Widget _buildEmpty(BuildContext context, Color mutedColor) {
    return Row(
      children: [
        Text(
          'No audience profile set yet.',
          style: AppFonts.inter(fontSize: 14, color: mutedColor)
              .copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(width: AppSpacing.sm),
        TextButton(
          onPressed: () => context.go('/app/audience'),
          child: Text(
            'Add',
            style: AppFonts.inter(fontSize: 14, color: mutedColor),
          ),
        ),
      ],
    );
  }
}
