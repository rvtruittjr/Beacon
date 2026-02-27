import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../providers/asset_library_provider.dart';

class CollectionsSidebar extends ConsumerWidget {
  const CollectionsSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider);
    final assetsAsync = ref.watch(assetsProvider);
    final filters = ref.watch(assetFilterProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    final totalCount = assetsAsync.when(
      data: (a) => a.length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading
          Text(
            'COLLECTIONS',
            style: AppFonts.inter(fontSize: 12, color: mutedColor)
                .copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2),
          ),
          const SizedBox(height: AppSpacing.md),
          // All Assets
          _CollectionItem(
            label: 'All Assets',
            count: totalCount,
            isActive: filters.collectionId == null,
            onTap: () =>
                ref.read(assetFilterProvider.notifier).setCollection(null),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Collection list
          collectionsAsync.when(
            loading: () => Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            error: (_, __) => Text(
              'Failed to load',
              style: TextStyle(color: mutedColor, fontSize: 12),
            ),
            data: (collections) => Column(
              children: collections
                  .map((c) => _CollectionItem(
                        label: c.name,
                        isActive: filters.collectionId == c.id,
                        onTap: () => ref
                            .read(assetFilterProvider.notifier)
                            .setCollection(c.id),
                        onContextMenu: (pos) =>
                            _showCollectionMenu(context, ref, c.id, c.name, pos),
                      ))
                  .toList(),
            ),
          ),
          const Spacer(),
          // New collection button
          AppButton(
            label: '+ New Collection',
            variant: AppButtonVariant.ghost,
            onPressed: () => _createCollection(context, ref),
          ),
        ],
      ),
    );
  }

  void _createCollection(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Collection'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Collection name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              final brandId = ref.read(currentBrandProvider);
              if (brandId == null) return;
              await ref
                  .read(assetLibraryRepositoryProvider)
                  .createCollection(brandId: brandId, name: name);
              ref.invalidate(collectionsProvider);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showCollectionMenu(
    BuildContext context,
    WidgetRef ref,
    String collectionId,
    String currentName,
    Offset position,
  ) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: const [
        PopupMenuItem(value: 'rename', child: Text('Rename')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    ).then((value) {
      if (value == 'rename') {
        _renameCollection(context, ref, collectionId, currentName);
      }
      if (value == 'delete') {
        _deleteCollection(ref, collectionId);
      }
    });
  }

  void _renameCollection(
    BuildContext context,
    WidgetRef ref,
    String id,
    String currentName,
  ) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Collection'),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              await ref
                  .read(assetLibraryRepositoryProvider)
                  .updateAsset(id, name: name);
              ref.invalidate(collectionsProvider);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCollection(WidgetRef ref, String id) async {
    // Just remove the collection; assets stay but lose their collection_id
    await ref.read(assetLibraryRepositoryProvider).deleteAsset(id);
    ref.invalidate(collectionsProvider);
    ref.read(assetFilterProvider.notifier).setCollection(null);
  }
}

class _CollectionItem extends StatelessWidget {
  const _CollectionItem({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.count,
    this.onContextMenu,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final int? count;
  final void Function(Offset position)? onContextMenu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return GestureDetector(
      onTap: onTap,
      onSecondaryTapUp: onContextMenu != null
          ? (details) => onContextMenu!(details.globalPosition)
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          border: isActive
              ? Border(
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppFonts.inter(
                  fontSize: 14,
                  color: isActive ? textColor : mutedColor,
                ).copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (count != null)
              Text(
                '$count',
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
