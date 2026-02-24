import 'package:flutter/material.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../models/audience_model.dart';

/// Summary card showing persona name, demographic chips, and top interests/pain
/// points/goals. Used in Brand Snapshot.
class PersonaCard extends StatelessWidget {
  const PersonaCard({super.key, required this.audience});

  final AudienceModel audience;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.all(AppRadius.lg),
        boxShadow: isDark ? null : AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Persona name
          Text(
            audience.personaName?.isNotEmpty == true
                ? audience.personaName!
                : 'Unnamed Persona',
            style: AppFonts.clashDisplay(fontSize: 20, color: textColor),
          ),

          // Demographics row
          if (_hasDemographics) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (audience.ageRangeMin != null || audience.ageRangeMax != null)
                  AppBadge(
                    label: _ageLabel,
                    variant: AppBadgeVariant.standard,
                  ),
                if (audience.genderSkew != null)
                  AppBadge(
                    label: audience.genderSkew!,
                    variant: AppBadgeVariant.standard,
                  ),
                ...audience.locations.take(3).map((l) => AppBadge(
                      label: l,
                      variant: AppBadgeVariant.standard,
                    )),
              ],
            ),
          ],

          // Interests (lime)
          if (audience.interests.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _ChipGroup(
              label: 'Interests',
              items: audience.interests.take(3).toList(),
              chipColor: AppColors.blockLime,
              chipTextColor: AppColors.textOnLime,
              mutedColor: mutedColor,
            ),
          ],

          // Pain points (coral)
          if (audience.painPoints.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _ChipGroup(
              label: 'Pain Points',
              items: audience.painPoints.take(3).toList(),
              chipColor: AppColors.blockCoral,
              chipTextColor: AppColors.textOnCoral,
              mutedColor: mutedColor,
            ),
          ],

          // Goals (yellow)
          if (audience.goals.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _ChipGroup(
              label: 'Goals',
              items: audience.goals.take(3).toList(),
              chipColor: AppColors.blockYellow,
              chipTextColor: AppColors.textOnYellow,
              mutedColor: mutedColor,
            ),
          ],
        ],
      ),
    );
  }

  bool get _hasDemographics =>
      audience.ageRangeMin != null ||
      audience.ageRangeMax != null ||
      audience.genderSkew != null ||
      audience.locations.isNotEmpty;

  String get _ageLabel {
    final min = audience.ageRangeMin;
    final max = audience.ageRangeMax;
    if (min != null && max != null) return '$min–$max';
    if (min != null) return '$min+';
    if (max != null) return 'Under $max';
    return '';
  }
}

class _ChipGroup extends StatelessWidget {
  const _ChipGroup({
    required this.label,
    required this.items,
    required this.chipColor,
    required this.chipTextColor,
    required this.mutedColor,
  });

  final String label;
  final List<String> items;
  final Color chipColor;
  final Color chipTextColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppFonts.inter(fontSize: 11, color: mutedColor)
              .copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: items
                .map((item) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: chipColor,
                        borderRadius: BorderRadius.all(AppRadius.full),
                      ),
                      child: Text(
                        item,
                        style: TextStyle(
                          color: chipTextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
