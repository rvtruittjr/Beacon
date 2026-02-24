import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/config/design_tokens.dart';
import '../../../core/config/app_fonts.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/shimmer_card.dart';
import '../../../shared/widgets/platform_adaptive/adaptive_dialog.dart';
import '../data/archive_repository.dart';
import '../providers/archive_provider.dart';
import 'widgets/archive_card.dart';
import 'widgets/archive_form_dialog.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  static const _platformPills = [
    'All',
    'YouTube',
    'TikTok',
    'Instagram',
    'Twitter/X',
    'Newsletter',
    'Podcast',
    'Other',
  ];

  static const _sortOptions = {
    'created_at': 'Newest',
    'views': 'Most Views',
    'likes': 'Most Likes',
    'comments': 'Most Comments',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    final itemsAsync = ref.watch(archiveItemsProvider);
    final activePlatform = ref.watch(archivePlatformFilterProvider);
    final activePillar = ref.watch(archivePillarFilterProvider);
    final activeSort = ref.watch(archiveSortProvider);
    final pillarsAsync = ref.watch(archivePillarsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Content Archive',
                      style: AppFonts.clashDisplay(
                          fontSize: 32, color: textColor),
                    ),
                  ),
                  AppButton(
                    label: 'Add content',
                    icon: LucideIcons.plus,
                    onPressed: () => _showAddDialog(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Filter bar
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Platform pills
                  ..._platformPills.map((p) {
                    final isActive =
                        (p == 'All' && activePlatform == null) ||
                            p == activePlatform;
                    return _FilterPill(
                      label: p,
                      isActive: isActive,
                      onTap: () {
                        ref.read(archivePlatformFilterProvider.notifier).state =
                            p == 'All' ? null : p;
                      },
                    );
                  }),

                  const SizedBox(width: AppSpacing.sm),

                  // Pillar dropdown
                  pillarsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (pillars) {
                      if (pillars.isEmpty) return const SizedBox.shrink();
                      return _DropdownPill(
                        value: activePillar,
                        hint: 'All Pillars',
                        items: {
                          for (final p in pillars)
                            p['id'] as String: p['name'] as String? ?? '',
                        },
                        onChanged: (v) {
                          ref
                              .read(archivePillarFilterProvider.notifier)
                              .state = v;
                        },
                      );
                    },
                  ),

                  // Sort dropdown
                  _DropdownPill(
                    value: activeSort,
                    hint: 'Sort',
                    items: _sortOptions,
                    onChanged: (v) {
                      ref.read(archiveSortProvider.notifier).state =
                          v ?? 'created_at';
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Content
              Expanded(
                child: itemsAsync.when(
                  loading: () => LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = constraints.maxWidth > 900
                          ? 3
                          : constraints.maxWidth > 500
                              ? 2
                              : 1;
                      return ShimmerGrid(
                        crossAxisCount: cols,
                        itemCount: 6,
                        aspectRatio: 0.75,
                      );
                    },
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      'Failed to load archive.',
                      style: TextStyle(color: mutedColor),
                    ),
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return EmptyState(
                        blockColor: AppColors.blockCoral,
                        icon: LucideIcons.archive,
                        headline: 'Your hall of fame awaits.',
                        supportingText:
                            'Archive your best content here to track what works.',
                        ctaLabel: 'Add your first win',
                        onCtaPressed: () => _showAddDialog(context, ref),
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount =
                            constraints.maxWidth > 900
                                ? 3
                                : constraints.maxWidth > 500
                                    ? 2
                                    : 1;
                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ArchiveCard(
                              item: item,
                              onEdit: () =>
                                  _showEditDialog(context, ref, item),
                              onDelete: () => _deleteItem(ref, item.id!),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    AdaptiveDialog.show(
      context: context,
      child: const ArchiveFormDialog(),
    );
  }

  void _showEditDialog(
      BuildContext context, WidgetRef ref, dynamic item) {
    AdaptiveDialog.show(
      context: context,
      child: ArchiveFormDialog(existing: item),
    );
  }

  Future<void> _deleteItem(WidgetRef ref, String id) async {
    await ref.read(archiveRepositoryProvider).deleteArchiveItem(id);
    ref.invalidate(archiveItemsProvider);
  }
}

// ── Filter pill ─────────────────────────────────────────────────

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.blockCoral
              : isDark
                  ? AppColors.surfaceMidDark
                  : AppColors.surfaceMidLight,
          borderRadius: BorderRadius.all(AppRadius.full),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive
                ? AppColors.textOnCoral
                : isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
          ),
        ),
      ),
    );
  }
}

// ── Dropdown pill ───────────────────────────────────────────────

class _DropdownPill extends StatelessWidget {
  const _DropdownPill({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final String? value;
  final String hint;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.surfaceMidDark : AppColors.surfaceMidLight;
    final fgColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(AppRadius.full),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(color: fgColor, fontSize: 13)),
          icon: Icon(LucideIcons.chevronDown, size: 14, color: fgColor),
          isDense: true,
          style: TextStyle(color: fgColor, fontSize: 13),
          dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(hint),
            ),
            ...items.entries.map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value),
                )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
