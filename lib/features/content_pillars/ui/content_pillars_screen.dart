import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/config/design_tokens.dart';
import '../../../core/config/app_fonts.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/platform_adaptive/adaptive_dialog.dart';
import '../data/content_pillar_repository.dart';
import '../providers/content_pillar_provider.dart';
import '../../brand_snapshot/providers/snapshot_provider.dart';
import '../../content_archive/providers/archive_provider.dart';
import 'widgets/pillar_card.dart';
import 'widgets/pillar_form_dialog.dart';

class ContentPillarsScreen extends ConsumerWidget {
  const ContentPillarsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final pillarsAsync = ref.watch(contentPillarsListProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Content Pillars',
                      style:
                          AppFonts.clashDisplay(fontSize: 32, color: textColor),
                    ),
                  ),
                  AppButton(
                    label: 'Add pillar',
                    icon: LucideIcons.plus,
                    onPressed: () => _showAddDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Define the core themes your content revolves around.',
                style: AppFonts.inter(fontSize: 14, color: mutedColor),
              ),
              const SizedBox(height: AppSpacing.x2l),

              // Content
              Expanded(
                child: pillarsAsync.when(
                  loading: () =>
                      const LoadingIndicator(caption: 'Loading pillars…'),
                  error: (_, __) => ErrorState(
                    message: 'Failed to load content pillars.',
                    onRetry: () => ref.invalidate(contentPillarsListProvider),
                  ),
                  data: (pillars) {
                    if (pillars.isEmpty) {
                      return EmptyState(
                        blockColor: AppColors.blockViolet,
                        icon: LucideIcons.layoutGrid,
                        headline: 'No content pillars yet.',
                        supportingText:
                            'Define the themes that guide your content strategy.',
                        ctaLabel: 'Add your first pillar',
                        onCtaPressed: () => _showAddDialog(context),
                      );
                    }

                    return ListView.separated(
                      itemCount: pillars.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final pillar = pillars[index];
                        return SizedBox(
                          height: pillar.description != null &&
                                  pillar.description!.isNotEmpty
                              ? 90
                              : 60,
                          child: PillarCard(
                            pillar: pillar,
                            onEdit: () => _showEditDialog(context, pillar),
                            onDelete: () =>
                                _confirmDelete(context, ref, pillar),
                          ),
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

  void _showAddDialog(BuildContext context) {
    AdaptiveDialog.show(
      context: context,
      child: const PillarFormDialog(),
    );
  }

  void _showEditDialog(BuildContext context, dynamic pillar) {
    AdaptiveDialog.show(
      context: context,
      child: PillarFormDialog(existing: pillar),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, dynamic pillar) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete pillar?'),
        content: Text('Are you sure you want to delete "${pillar.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(contentPillarRepositoryProvider).deletePillar(pillar.id!);
      ref.invalidate(contentPillarsListProvider);
      ref.invalidate(snapshotProvider);
      ref.invalidate(archivePillarsProvider);
    }
  }
}
