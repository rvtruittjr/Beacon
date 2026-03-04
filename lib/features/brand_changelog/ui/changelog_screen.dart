import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/design_tokens.dart';
import '../../../core/config/app_fonts.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/changelog_provider.dart';
import 'widgets/timeline_tile.dart';

class ChangelogScreen extends ConsumerWidget {
  const ChangelogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final entriesAsync = ref.watch(changelogEntriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0,
          ),
          child: Text(
            'Changelog',
            style: AppFonts.clashDisplay(fontSize: 32, color: textColor),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: entriesAsync.when(
            loading: () => const LoadingIndicator(),
            error: (_, __) =>
                const Center(child: Text('Failed to load changelog')),
            data: (entries) {
              if (entries.isEmpty) {
                return EmptyState(
                  blockColor: AppColors.blockYellow,
                  icon: Icons.history,
                  headline: 'No changes yet',
                  supportingText:
                      'Changes to your brand kit will appear here.',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                itemCount: entries.length,
                itemBuilder: (context, index) => TimelineTile(
                  entry: entries[index],
                  isLast: index == entries.length - 1,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
