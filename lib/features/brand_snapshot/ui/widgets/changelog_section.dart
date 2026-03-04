import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../brand_changelog/models/changelog_entry_model.dart';
import '../../../brand_changelog/providers/changelog_provider.dart';

class ChangelogSection extends ConsumerWidget {
  const ChangelogSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    final entriesAsync = ref.watch(changelogEntriesProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.all(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.history, size: 20, color: textColor),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Recent Changes',
                style: AppFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          entriesAsync.when(
            loading: () => const SizedBox(
              height: 60,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (_, __) => Text(
              'Could not load changes',
              style: AppFonts.inter(fontSize: 13, color: mutedColor),
            ),
            data: (entries) {
              if (entries.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text(
                    'No changes recorded yet.',
                    style: AppFonts.inter(fontSize: 13, color: mutedColor),
                  ),
                );
              }

              // Show up to 8 most recent entries
              final shown = entries.take(8).toList();
              return Column(
                children: shown.asMap().entries.map((e) {
                  final index = e.key;
                  final entry = e.value;
                  return _CompactTimelineEntry(
                    entry: entry,
                    isLast: index == shown.length - 1,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CompactTimelineEntry extends StatelessWidget {
  const _CompactTimelineEntry({
    required this.entry,
    required this.isLast,
  });

  final ChangelogEntryModel entry;
  final bool isLast;

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

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: _badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.all(AppRadius.full),
            ),
            child: Text(
              entry.action.toUpperCase(),
              style: AppFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: _badgeColor,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              entry.summary,
              style: AppFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _relativeTime,
            style: AppFonts.inter(fontSize: 11, color: mutedColor),
          ),
        ],
      ),
    );
  }
}
