import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../models/changelog_entry_model.dart';

class TimelineTile extends StatelessWidget {
  const TimelineTile({
    super.key,
    required this.entry,
    required this.isLast,
  });

  final ChangelogEntryModel entry;
  final bool isLast;

  IconData get _icon => switch (entry.entityType) {
        'color' => Icons.palette_outlined,
        'font' => LucideIcons.type,
        'logo' => LucideIcons.image,
        'voice' => LucideIcons.mic2,
        'audience' => LucideIcons.users,
        'pillar' => LucideIcons.layoutGrid,
        _ => LucideIcons.edit3,
      };

  Color get _dotColor => switch (entry.entityType) {
        'color' => AppColors.blockViolet,
        'font' => AppColors.blockCoral,
        'logo' => AppColors.blockLime,
        'voice' => AppColors.blockYellow,
        'audience' => const Color(0xFF1DA1F2),
        'pillar' => const Color(0xFF14B8A6),
        _ => AppColors.blockViolet,
      };

  Color get _badgeColor => switch (entry.action) {
        'added' => AppColors.success,
        'updated' => AppColors.warning,
        'deleted' => AppColors.error,
        _ => AppColors.blockViolet,
      };

  String get _relativeTime {
    final diff = DateTime.now().difference(entry.createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final d = entry.createdAt;
    return '${d.month}/${d.day}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _dotColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_icon, size: 16, color: _dotColor),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _badgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.all(AppRadius.full),
                        ),
                        child: Text(
                          entry.action.toUpperCase(),
                          style: AppFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _badgeColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _relativeTime,
                        style:
                            AppFonts.inter(fontSize: 12, color: mutedColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.summary,
                    style: AppFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
