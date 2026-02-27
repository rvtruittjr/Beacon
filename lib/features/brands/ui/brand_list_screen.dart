import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/config/design_tokens.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../providers/brand_provider.dart';
import 'create_brand_screen.dart';
import 'widgets/brand_card.dart';

class BrandListScreen extends ConsumerWidget {
  const BrandListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandsAsync = ref.watch(userBrandsProvider);

    return brandsAsync.when(
      loading: () => const LoadingIndicator(caption: 'Loading brands...'),
      error: (error, _) => ErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(userBrandsProvider),
      ),
      data: (brands) {
        if (brands.isEmpty) {
          return EmptyState(
            blockColor: AppColors.blockYellow,
            icon: LucideIcons.star,
            headline: 'Create your first brand.',
            supportingText:
                'Every great creator starts with a brand. Set yours up in minutes.',
            ctaLabel: 'Create brand',
            onCtaPressed: () => _showCreateBrand(context, ref),
          );
        }

        return _buildGrid(context, ref, brands);
      },
    );
  }

  Widget _buildGrid(BuildContext context, WidgetRef ref, List brands) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 900 ? 3 : 2;

          return Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              ...brands.map((brand) {
                return SizedBox(
                  width: (constraints.maxWidth -
                          (crossAxisCount - 1) * AppSpacing.md) /
                      crossAxisCount,
                  child: BrandCard(
                    brand: brand,
                    onOpen: () {
                      ref.read(currentBrandProvider.notifier).state = brand.id;
                      context.go('/app/snapshot');
                    },
                  ),
                );
              }),
              // New brand card
              SizedBox(
                width: (constraints.maxWidth -
                        (crossAxisCount - 1) * AppSpacing.md) /
                    crossAxisCount,
                child: _NewBrandCard(
                  borderColor: borderColor,
                  onTap: () => _showCreateBrand(context, ref),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCreateBrand(BuildContext context, WidgetRef ref) {
    CreateBrandScreen.show(context, ref);
  }
}

class _NewBrandCard extends StatefulWidget {
  const _NewBrandCard({required this.borderColor, required this.onTap});
  final Color borderColor;
  final VoidCallback onTap;

  @override
  State<_NewBrandCard> createState() => _NewBrandCardState();
}

class _NewBrandCardState extends State<_NewBrandCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(AppRadius.md),
            border: Border.all(
              color: _isHovered
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.6)
                  : widget.borderColor,
              width: 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.plus, size: 32, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'New brand',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
