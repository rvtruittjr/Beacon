import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/config/design_tokens.dart';
import '../../../core/config/app_fonts.dart';
import '../../../core/providers/app_providers.dart';
import '../../../features/brands/providers/brand_provider.dart';
import '../../../features/brands/ui/create_brand_screen.dart';

class BrandSwitcher extends ConsumerWidget {
  const BrandSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandsAsync = ref.watch(userBrandsProvider);
    final currentBrandId = ref.watch(currentBrandProvider);

    final brandList = brandsAsync.valueOrNull ?? [];
    final hasBrands = brandList.isNotEmpty;

    final currentName = brandsAsync.whenOrNull(
      data: (list) {
        if (list.isEmpty) return 'Create a brand';
        if (currentBrandId == null && list.isNotEmpty) {
          Future.microtask(() {
            ref.read(currentBrandProvider.notifier).state = list.first.id;
          });
          return list.first.name;
        }
        final match = list.where((b) => b.id == currentBrandId);
        return match.isNotEmpty ? match.first.name : 'Select brand';
      },
    );

    return InkWell(
      borderRadius: BorderRadius.all(AppRadius.md),
      onTap: () {
        if (!hasBrands) {
          CreateBrandScreen.show(context, ref);
        } else {
          _showBrandPopover(context, ref);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: AppColors.sidebarSurface,
          borderRadius: BorderRadius.all(AppRadius.md),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                currentName ?? 'Loading...',
                style: AppFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.sidebarText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              LucideIcons.chevronDown,
              size: 16,
              color: AppColors.sidebarMuted,
            ),
          ],
        ),
      ),
    );
  }

  void _showBrandPopover(BuildContext context, WidgetRef ref) {
    final brands = ref.read(userBrandsProvider).valueOrNull ?? [];
    final currentBrandId = ref.read(currentBrandProvider);
    final theme = Theme.of(context);

    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(AppRadius.lg),
      ),
      items: [
        ...brands.map((brand) {
          final isActive = brand.id == currentBrandId;
          return PopupMenuItem<String>(
            value: brand.id,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    brand.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? AppColors.blockYellow : null,
                    ),
                  ),
                ),
                if (isActive)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: const Icon(
                      LucideIcons.check,
                      size: 16,
                      color: AppColors.blockYellow,
                    ),
                  ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(); // close menu first
                    _confirmDeleteBrand(context, ref, brand.id, brand.name);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      LucideIcons.trash2,
                      size: 14,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: '__new__',
          child: Row(
            children: [
              Icon(LucideIcons.plus, size: 16, color: theme.colorScheme.outline),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'New brand',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == null) return;
      if (value == '__new__') {
        if (context.mounted) {
          CreateBrandScreen.show(context, ref);
        }
        return;
      }
      ref.read(currentBrandProvider.notifier).state = value;
    });
  }

  void _confirmDeleteBrand(
    BuildContext context,
    WidgetRef ref,
    String brandId,
    String brandName,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.lg),
        ),
        title: const Text('Delete brand?'),
        content: Text(
          'This will permanently delete "$brandName" and all its data '
          '(colors, fonts, logos, voice, assets). This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(brandRepositoryProvider).deleteBrand(brandId);

              // If we deleted the active brand, switch to another or clear
              if (ref.read(currentBrandProvider) == brandId) {
                ref.read(currentBrandProvider.notifier).state = null;
              }
              ref.invalidate(userBrandsProvider);
              ref.invalidate(activeBrandProvider);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
