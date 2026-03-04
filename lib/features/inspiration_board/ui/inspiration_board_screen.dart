import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/design_tokens.dart';
import '../../../core/config/app_fonts.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/platform_adaptive/adaptive_dialog.dart';
import '../providers/inspiration_provider.dart';
import 'widgets/add_item_dialog.dart';
import 'widgets/board_item.dart';

class InspirationBoardScreen extends ConsumerStatefulWidget {
  const InspirationBoardScreen({super.key});

  @override
  ConsumerState<InspirationBoardScreen> createState() =>
      _InspirationBoardScreenState();
}

class _InspirationBoardScreenState
    extends ConsumerState<InspirationBoardScreen> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final itemsAsync = ref.watch(inspirationItemsProvider);

    // Sync DB items into local board state on first load
    itemsAsync.whenData((items) {
      if (!_initialized) {
        Future.microtask(() {
          ref.read(boardStateProvider.notifier).setItems(items);
          _initialized = true;
        });
      }
    });

    final boardItems = ref.watch(boardStateProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0,
          ),
          child: Row(
            children: [
              Text(
                'Moodboard',
                style: AppFonts.clashDisplay(fontSize: 32, color: textColor),
              ),
              const Spacer(),
              AppButton(
                label: 'Add',
                icon: Icons.add,
                onPressed: () => _addItem(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: itemsAsync.when(
            loading: () => const LoadingIndicator(),
            error: (_, __) =>
                const Center(child: Text('Failed to load board')),
            data: (_) {
              if (boardItems.isEmpty && _initialized) {
                return EmptyState(
                  blockColor: AppColors.blockCoral,
                  icon: Icons.dashboard_outlined,
                  headline: 'Your moodboard is empty',
                  supportingText:
                      'Add images and inspiration to build your brand vision.',
                  ctaLabel: 'Add first item',
                  onCtaPressed: () => _addItem(context),
                );
              }

              return InteractiveViewer(
                constrained: false,
                boundaryMargin: const EdgeInsets.all(2000),
                minScale: 0.3,
                maxScale: 2.0,
                child: SizedBox(
                  width: 3000,
                  height: 3000,
                  child: Stack(
                    children: boardItems.map((item) {
                      return Positioned(
                        left: item.posX,
                        top: item.posY,
                        child: BoardItem(
                          key: ValueKey(item.id),
                          item: item,
                          onMoved: (dx, dy) {
                            ref
                                .read(boardStateProvider.notifier)
                                .moveItem(item.id, dx, dy);
                          },
                          onDragEnd: () => _persistPosition(item.id),
                          onResized: (dw, dh) {
                            ref
                                .read(boardStateProvider.notifier)
                                .resizeItem(item.id, dw, dh);
                          },
                          onResizeEnd: () => _persistSize(item.id),
                          onDelete: () => _deleteItem(item.id),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _addItem(BuildContext context) async {
    final imageUrl = await AdaptiveDialog.show<String>(
      context: context,
      child: const AddInspirationItemDialog(),
    );
    if (imageUrl == null || imageUrl.isEmpty) return;

    final brandId = ref.read(currentBrandProvider);
    if (brandId == null) return;

    final repo = ref.read(inspirationRepositoryProvider);
    final item = await repo.addItem(
      brandId: brandId,
      imageUrl: imageUrl,
      posX: 100 + (ref.read(boardStateProvider).length * 30.0),
      posY: 100 + (ref.read(boardStateProvider).length * 30.0),
    );
    ref.read(boardStateProvider.notifier).addItem(item);
  }

  Future<void> _deleteItem(String id) async {
    ref.read(boardStateProvider.notifier).removeItem(id);
    await ref.read(inspirationRepositoryProvider).deleteItem(id);
  }

  void _persistPosition(String id) {
    final item = ref.read(boardStateProvider).where((i) => i.id == id).firstOrNull;
    if (item == null) return;
    ref.read(inspirationRepositoryProvider).updatePosition(id, item.posX, item.posY);
  }

  void _persistSize(String id) {
    final item = ref.read(boardStateProvider).where((i) => i.id == id).firstOrNull;
    if (item == null) return;
    ref.read(inspirationRepositoryProvider).updateSize(id, item.width, item.height);
  }
}
