import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/design_tokens.dart';
import '../../../core/config/app_fonts.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/platform_adaptive/adaptive_dialog.dart';
import '../models/board_item_type.dart';
import '../models/drawing_stroke.dart';
import '../models/inspiration_item_model.dart';
import '../providers/inspiration_provider.dart';
import '../providers/tool_state_provider.dart';
import 'widgets/add_item_dialog.dart';
import 'widgets/board_item.dart';
import 'widgets/board_toolbar.dart';
import 'widgets/drawing_canvas.dart';
import 'widgets/shape_item.dart';
import 'widgets/sticky_note_item.dart';
import 'widgets/text_item.dart';

class InspirationBoardScreen extends ConsumerStatefulWidget {
  const InspirationBoardScreen({super.key});

  @override
  ConsumerState<InspirationBoardScreen> createState() =>
      _InspirationBoardScreenState();
}

class _InspirationBoardScreenState
    extends ConsumerState<InspirationBoardScreen> {
  bool _initialized = false;

  /// Drawing strokes stored locally (persisted as items on stroke end).
  final List<DrawingStroke> _drawingStrokes = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final itemsAsync = ref.watch(inspirationItemsProvider);
    final activeTool = ref.watch(activeToolProvider);

    // Sync DB items into local board state on first load
    itemsAsync.whenData((items) {
      if (!_initialized) {
        Future.microtask(() {
          ref.read(boardStateProvider.notifier).setItems(items);
          // Extract drawing strokes from drawing-type items
          _drawingStrokes.clear();
          for (final item in items) {
            if (item.type == 'drawing') {
              try {
                _drawingStrokes.add(DrawingStroke.fromJson(item.data));
              } catch (_) {}
            }
          }
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
                label: 'Add Image',
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
              if (boardItems.isEmpty && _initialized && _drawingStrokes.isEmpty) {
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

              return Stack(
                children: [
                  // Main canvas
                  InteractiveViewer(
                    constrained: false,
                    boundaryMargin: const EdgeInsets.all(2000),
                    minScale: 0.3,
                    maxScale: 2.0,
                    panEnabled: activeTool == ToolMode.select,
                    scaleEnabled: activeTool == ToolMode.select,
                    child: SizedBox(
                      width: 3000,
                      height: 3000,
                      child: Stack(
                        children: [
                          // Drawing layer (bottom)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: DrawingCanvas(
                                strokes: _drawingStrokes,
                                activeStroke: ref.watch(activeStrokeProvider),
                              ),
                            ),
                          ),

                          // Board items layer
                          ..._buildBoardItems(boardItems),

                          // Gesture overlay for drawing / shape creation / text+sticky placement
                          if (activeTool != ToolMode.select)
                            Positioned.fill(
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onPanStart: (d) =>
                                    _onCanvasPanStart(d, activeTool),
                                onPanUpdate: (d) =>
                                    _onCanvasPanUpdate(d, activeTool),
                                onPanEnd: (d) =>
                                    _onCanvasPanEnd(d, activeTool),
                                onTapUp: (d) =>
                                    _onCanvasTap(d, activeTool),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Floating toolbar
                  Positioned(
                    bottom: AppSpacing.lg,
                    left: 0,
                    right: 0,
                    child: const Center(child: BoardToolbar()),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBoardItems(List<InspirationItemModel> items) {
    return items
        .where((item) => item.type != 'drawing')
        .map((item) {
      final Widget child = switch (item.type) {
        'sticky_note' => StickyNoteItem(
            key: ValueKey(item.id),
            item: item,
            onMoved: (dx, dy) =>
                ref.read(boardStateProvider.notifier).moveItem(item.id, dx, dy),
            onDragEnd: () => _persistPosition(item.id),
            onResized: (dw, dh) => ref
                .read(boardStateProvider.notifier)
                .resizeItem(item.id, dw, dh),
            onResizeEnd: () => _persistSize(item.id),
            onDelete: () => _deleteItem(item.id),
            onDataChanged: (data) => _updateData(item.id, data),
          ),
        'text' => TextItem(
            key: ValueKey(item.id),
            item: item,
            onMoved: (dx, dy) =>
                ref.read(boardStateProvider.notifier).moveItem(item.id, dx, dy),
            onDragEnd: () => _persistPosition(item.id),
            onDelete: () => _deleteItem(item.id),
            onDataChanged: (data) => _updateData(item.id, data),
          ),
        'shape' => ShapeItem(
            key: ValueKey(item.id),
            item: item,
            onMoved: (dx, dy) =>
                ref.read(boardStateProvider.notifier).moveItem(item.id, dx, dy),
            onDragEnd: () => _persistPosition(item.id),
            onResized: (dw, dh) => ref
                .read(boardStateProvider.notifier)
                .resizeItem(item.id, dw, dh),
            onResizeEnd: () => _persistSize(item.id),
            onDelete: () => _deleteItem(item.id),
          ),
        _ => BoardItem(
            key: ValueKey(item.id),
            item: item,
            onMoved: (dx, dy) =>
                ref.read(boardStateProvider.notifier).moveItem(item.id, dx, dy),
            onDragEnd: () => _persistPosition(item.id),
            onResized: (dw, dh) => ref
                .read(boardStateProvider.notifier)
                .resizeItem(item.id, dw, dh),
            onResizeEnd: () => _persistSize(item.id),
            onDelete: () => _deleteItem(item.id),
          ),
      };

      return Positioned(
        left: item.posX,
        top: item.posY,
        child: child,
      );
    }).toList();
  }

  // ---- Drawing gestures ----

  Offset? _shapeStart;

  void _onCanvasPanStart(DragStartDetails d, ToolMode tool) {
    if (tool == ToolMode.pen) {
      final pos = d.localPosition;
      ref.read(activeStrokeProvider.notifier).state = DrawingStroke(
        points: [DrawingPoint(pos.dx, pos.dy)],
        colorHex: ref.read(penColorProvider),
        strokeWidth: ref.read(penStrokeWidthProvider),
      );
    } else if (tool == ToolMode.shape) {
      _shapeStart = d.localPosition;
    }
  }

  void _onCanvasPanUpdate(DragUpdateDetails d, ToolMode tool) {
    if (tool == ToolMode.pen) {
      final current = ref.read(activeStrokeProvider);
      if (current == null) return;
      final pos = d.localPosition;
      // Skip points too close together to avoid jagged lines
      if (current.points.isNotEmpty) {
        final last = current.points.last;
        final dx = pos.dx - last.x;
        final dy = pos.dy - last.y;
        if (dx * dx + dy * dy < 9.0) return; // min 3px distance
      }
      ref.read(activeStrokeProvider.notifier).state = DrawingStroke(
        points: [...current.points, DrawingPoint(pos.dx, pos.dy)],
        colorHex: current.colorHex,
        strokeWidth: current.strokeWidth,
      );
    }
  }

  void _onCanvasPanEnd(DragEndDetails d, ToolMode tool) {
    if (tool == ToolMode.pen) {
      final stroke = ref.read(activeStrokeProvider);
      if (stroke != null && stroke.points.length >= 2) {
        setState(() => _drawingStrokes.add(stroke));
        _persistDrawingStroke(stroke);
      }
      ref.read(activeStrokeProvider.notifier).state = null;
    } else if (tool == ToolMode.shape && _shapeStart != null) {
      _createShapeItem(_shapeStart!.dx, _shapeStart!.dy);
      _shapeStart = null;
    }
  }

  void _onCanvasTap(TapUpDetails d, ToolMode tool) {
    final pos = d.localPosition;
    switch (tool) {
      case ToolMode.text:
        _createTextItem(pos.dx, pos.dy);
      case ToolMode.stickyNote:
        _createStickyNote(pos.dx, pos.dy);
      case ToolMode.shape:
        _createShapeItem(pos.dx, pos.dy);
      case ToolMode.eraser:
        _eraseAt(pos.dx, pos.dy);
      default:
        break;
    }
  }

  // ---- Item creation helpers ----

  Future<void> _createStickyNote(double x, double y) async {
    final brandId = ref.read(currentBrandProvider);
    if (brandId == null) return;

    try {
      final repo = ref.read(inspirationRepositoryProvider);
      final noteColor = ref.read(stickyNoteColorProvider);
      final item = await repo.addItem(
        brandId: brandId,
        posX: x,
        posY: y,
        width: 180,
        height: 140,
        type: 'sticky_note',
        data: {'text': '', 'bgColor': noteColor, 'textColor': '#000000'},
      );
      ref.read(boardStateProvider.notifier).addItem(item);
    } catch (e) {
      _showError('Failed to add sticky note: $e');
    }
  }

  Future<void> _createTextItem(double x, double y) async {
    final brandId = ref.read(currentBrandProvider);
    if (brandId == null) return;

    try {
      final repo = ref.read(inspirationRepositoryProvider);
      final item = await repo.addItem(
        brandId: brandId,
        posX: x,
        posY: y,
        width: 200,
        height: 40,
        type: 'text',
        data: {'text': 'Text', 'color': '#FFFFFF', 'fontSize': 18},
      );
      ref.read(boardStateProvider.notifier).addItem(item);
    } catch (e) {
      _showError('Failed to add text: $e');
    }
  }

  Future<void> _createShapeItem(double x, double y) async {
    final brandId = ref.read(currentBrandProvider);
    if (brandId == null) return;

    try {
      final repo = ref.read(inspirationRepositoryProvider);
      final shapeType = ref.read(shapeTypeProvider);
      final fillColor = ref.read(shapeFillColorProvider);
      final strokeColor = ref.read(shapeStrokeColorProvider);
      final item = await repo.addItem(
        brandId: brandId,
        posX: x,
        posY: y,
        width: shapeType == ShapeType.line || shapeType == ShapeType.arrow
            ? 200
            : 120,
        height: shapeType == ShapeType.line || shapeType == ShapeType.arrow
            ? 40
            : 120,
        type: 'shape',
        data: {
          'shapeType': shapeType.name,
          'fillColor': fillColor,
          'strokeColor': strokeColor,
          'strokeWidth': 2.0,
        },
      );
      ref.read(boardStateProvider.notifier).addItem(item);
    } catch (e) {
      _showError('Failed to add shape: $e');
    }
  }

  Future<void> _persistDrawingStroke(DrawingStroke stroke) async {
    final brandId = ref.read(currentBrandProvider);
    if (brandId == null) return;

    try {
      final repo = ref.read(inspirationRepositoryProvider);
      final item = await repo.addItem(
        brandId: brandId,
        posX: 0,
        posY: 0,
        width: 1,
        height: 1,
        type: 'drawing',
        data: stroke.toJson(),
      );
      ref.read(boardStateProvider.notifier).addItem(item);
    } catch (_) {}
  }

  void _eraseAt(double x, double y) {
    const threshold = 20.0;
    int? closest;
    double minDist = double.infinity;

    for (var i = 0; i < _drawingStrokes.length; i++) {
      for (final p in _drawingStrokes[i].points) {
        final dist = (p.x - x) * (p.x - x) + (p.y - y) * (p.y - y);
        if (dist < minDist) {
          minDist = dist;
          closest = i;
        }
      }
    }

    if (closest != null && minDist < threshold * threshold) {
      final idx = closest;
      setState(() => _drawingStrokes.removeAt(idx));
      final drawingItems = ref
          .read(boardStateProvider)
          .where((item) => item.type == 'drawing')
          .toList();
      if (idx < drawingItems.length) {
        _deleteItem(drawingItems[idx].id);
      }
    }
  }

  // ---- Existing helpers ----

  Future<void> _addItem(BuildContext context) async {
    final imageUrl = await AdaptiveDialog.show<String>(
      context: context,
      child: const AddInspirationItemDialog(),
    );
    if (imageUrl == null || imageUrl.isEmpty) return;

    final brandId = ref.read(currentBrandProvider);
    if (brandId == null) return;

    try {
      final repo = ref.read(inspirationRepositoryProvider);
      final item = await repo.addItem(
        brandId: brandId,
        imageUrl: imageUrl,
        posX: 100 + (ref.read(boardStateProvider).length * 30.0),
        posY: 100 + (ref.read(boardStateProvider).length * 30.0),
      );
      ref.read(boardStateProvider.notifier).addItem(item);
    } catch (e) {
      _showError('Failed to add item: $e');
    }
  }

  Future<void> _deleteItem(String id) async {
    ref.read(boardStateProvider.notifier).removeItem(id);
    try {
      await ref.read(inspirationRepositoryProvider).deleteItem(id);
    } catch (e) {
      _showError('Failed to delete item: $e');
    }
  }

  void _updateData(String id, Map<String, dynamic> data) {
    ref.read(boardStateProvider.notifier).updateItemData(id, data);
    ref.read(inspirationRepositoryProvider).updateData(id, data);
  }

  void _persistPosition(String id) {
    final item =
        ref.read(boardStateProvider).where((i) => i.id == id).firstOrNull;
    if (item == null) return;
    ref
        .read(inspirationRepositoryProvider)
        .updatePosition(id, item.posX, item.posY);
  }

  void _persistSize(String id) {
    final item =
        ref.read(boardStateProvider).where((i) => i.id == id).firstOrNull;
    if (item == null) return;
    ref
        .read(inspirationRepositoryProvider)
        .updateSize(id, item.width, item.height);
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          width: 320,
        ),
      );
    }
  }
}
