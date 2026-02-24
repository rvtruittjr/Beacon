import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/design_tokens.dart';
import '../../../core/config/app_fonts.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer_card.dart';
import '../../../shared/widgets/upgrade_sheet.dart';
import '../../../core/errors/app_exception.dart';
import '../providers/asset_library_provider.dart';
import 'widgets/asset_card.dart';
import 'widgets/collections_sidebar.dart';

class AssetLibraryScreen extends ConsumerStatefulWidget {
  const AssetLibraryScreen({super.key});

  @override
  ConsumerState<AssetLibraryScreen> createState() => _AssetLibraryScreenState();
}

class _AssetLibraryScreenState extends ConsumerState<AssetLibraryScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  bool _isDragOver = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(assetFilterProvider.notifier).setSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final isDesktop = MediaQuery.sizeOf(context).width > 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + upload button
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0,
          ),
          child: Row(
            children: [
              Text(
                'Asset Library',
                style: AppFonts.clashDisplay(fontSize: 32, color: textColor),
              ),
              const Spacer(),
              AppButton(
                label: 'Upload',
                icon: Icons.add,
                onPressed: _pickAndUpload,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Mobile: horizontal collection tabs
        if (!isDesktop) _buildMobileCollectionTabs(),
        // Main content
        Expanded(
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 240,
                      child: CollectionsSidebar(),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: _buildMainArea()),
                  ],
                )
              : _buildMainArea(),
        ),
      ],
    );
  }

  Widget _buildMobileCollectionTabs() {
    final collectionsAsync = ref.watch(collectionsProvider);
    final filters = ref.watch(assetFilterProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return collectionsAsync.when(
      loading: () => const SizedBox(height: 40),
      error: (_, __) => const SizedBox.shrink(),
      data: (collections) => SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          children: [
            _CollectionChip(
              label: 'All',
              isActive: filters.collectionId == null,
              onTap: () =>
                  ref.read(assetFilterProvider.notifier).setCollection(null),
            ),
            ...collections.map((c) => _CollectionChip(
                  label: c.name,
                  isActive: filters.collectionId == c.id,
                  onTap: () =>
                      ref.read(assetFilterProvider.notifier).setCollection(c.id),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildMainArea() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final filters = ref.watch(assetFilterProvider);
    final assetsAsync = ref.watch(assetsProvider);

    return DragTarget<Object>(
      onWillAcceptWithDetails: (_) {
        setState(() => _isDragOver = true);
        return true;
      },
      onLeave: (_) => setState(() => _isDragOver = false),
      onAcceptWithDetails: (_) {
        setState(() => _isDragOver = false);
        _pickAndUpload();
      },
      builder: (context, candidateData, rejectedData) {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search assets…',
                      prefixIcon: Icon(Icons.search, color: mutedColor),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(AppRadius.lg),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Filter pills
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _FilterPill(
                          label: 'All',
                          isActive: filters.fileType == null,
                          onTap: () => ref
                              .read(assetFilterProvider.notifier)
                              .setFileType(null),
                        ),
                        _FilterPill(
                          label: 'Images',
                          isActive: filters.fileType == 'image',
                          onTap: () => ref
                              .read(assetFilterProvider.notifier)
                              .setFileType('image'),
                        ),
                        _FilterPill(
                          label: 'Video',
                          isActive: filters.fileType == 'video',
                          onTap: () => ref
                              .read(assetFilterProvider.notifier)
                              .setFileType('video'),
                        ),
                        _FilterPill(
                          label: 'Documents',
                          isActive: filters.fileType == 'document',
                          onTap: () => ref
                              .read(assetFilterProvider.notifier)
                              .setFileType('document'),
                        ),
                        _FilterPill(
                          label: 'Fonts',
                          isActive: filters.fileType == 'font',
                          onTap: () => ref
                              .read(assetFilterProvider.notifier)
                              .setFileType('font'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Grid
                  Expanded(
                    child: assetsAsync.when(
                      loading: () => LayoutBuilder(
                        builder: (context, constraints) {
                          final cols = constraints.maxWidth > 900
                              ? 3
                              : constraints.maxWidth > 500
                                  ? 2
                                  : 1;
                          return ShimmerGrid(
                              crossAxisCount: cols, itemCount: 6);
                        },
                      ),
                      error: (_, __) =>
                          const Center(child: Text('Failed to load assets')),
                      data: (assets) {
                        if (assets.isEmpty) {
                          return _buildEmptyState(filters);
                        }
                        return _buildGrid(assets);
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Drag overlay
            if (_isDragOver)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDark.withValues(alpha: 0.8),
                    border: Border.all(
                      color: AppColors.blockLime,
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                    borderRadius: BorderRadius.all(AppRadius.lg),
                  ),
                  child: Center(
                    child: Text(
                      'Drop to upload',
                      style: AppFonts.clashDisplay(
                        fontSize: 24,
                        color: AppColors.blockLime,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildGrid(List assets) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth > 900) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 500) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 0.85,
          ),
          itemCount: assets.length,
          itemBuilder: (context, index) => AssetCard(
            asset: assets[index],
            onDelete: () async {
              await ref
                  .read(assetLibraryRepositoryProvider)
                  .deleteAsset(assets[index].id);
              ref.invalidate(assetsProvider);
            },
            onRename: (newName) async {
              await ref
                  .read(assetLibraryRepositoryProvider)
                  .updateAsset(assets[index].id, name: newName);
              ref.invalidate(assetsProvider);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(AssetFilterState filters) {
    if (filters.searchQuery.isNotEmpty) {
      return EmptyState(
        blockColor: AppColors.blockYellow,
        icon: Icons.search_off,
        headline: 'No assets match your search.',
        supportingText: 'Try different keywords or clear your filters.',
        ctaLabel: 'Clear filters',
        onCtaPressed: () {
          _searchController.clear();
          ref.read(assetFilterProvider.notifier).clearAll();
        },
      );
    }

    if (filters.collectionId != null) {
      return EmptyState(
        blockColor: AppColors.blockCoral,
        icon: Icons.inventory_2_outlined,
        headline: 'Nothing in this collection.',
        supportingText: 'Upload assets or move existing ones here.',
        ctaLabel: 'Upload assets',
        onCtaPressed: _pickAndUpload,
      );
    }

    return EmptyState(
      blockColor: AppColors.blockViolet,
      icon: Icons.folder_open_outlined,
      headline: 'Your library is empty.',
      supportingText: 'Upload your brand assets to keep them organized.',
      ctaLabel: 'Upload your first asset',
      onCtaPressed: _pickAndUpload,
    );
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final brandId = ref.read(currentBrandProvider);
    if (brandId == null) return;

    final filters = ref.read(assetFilterProvider);

    for (final file in result.files) {
      if (file.bytes == null) continue;
      try {
        await ref.read(assetLibraryRepositoryProvider).uploadAsset(
              brandId: brandId,
              collectionId: filters.collectionId,
              file: file,
              name: file.name,
            );
      } on UpgradeRequiredException catch (e) {
        if (mounted) {
          showUpgradeSheet(
            context,
            feature: e.feature == 'storage_limit'
                ? 'More Storage'
                : 'Unlimited Assets',
            description: e.feature == 'storage_limit'
                ? "You've used your free 250 MB storage. Upgrade to Pro for 50 GB."
                : 'Your free library is full. Upgrade to Pro for unlimited assets.',
          );
        }
        break;
      } catch (_) {
        // Individual file upload failure
      }
    }
    ref.invalidate(assetsProvider);
  }
}

// ─── Small UI components ─────────────────────────────────────

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

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.blockLime
                : (isDark ? AppColors.surfaceMidDark : AppColors.surfaceMidLight),
            borderRadius: BorderRadius.all(AppRadius.full),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive
                  ? AppColors.textOnLime
                  : (isDark ? AppColors.mutedDark : AppColors.mutedLight),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _CollectionChip extends StatelessWidget {
  const _CollectionChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.blockLime : Colors.transparent,
            borderRadius: BorderRadius.all(AppRadius.full),
            border: isActive
                ? null
                : Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive
                  ? AppColors.textOnLime
                  : (Theme.of(context).brightness == Brightness.dark
                      ? AppColors.mutedDark
                      : AppColors.mutedLight),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
