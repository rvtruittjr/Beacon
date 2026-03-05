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
import 'widgets/connector_item.dart';
import 'widgets/line_item.dart';
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

                          // Line preview while dragging
                          Positioned.fill(
                            child: _LinePreview(ref: ref),
                          ),

                          // Connector items (below regular items so they appear as lines behind)
                          ..._buildConnectors(boardItems),

                          // Line items (absolute coordinates)
                          ..._buildLineItems(boardItems),

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

  List<Widget> _buildConnectors(List<InspirationItemModel> items) {
    return items
        .where((item) => item.type == 'connector')
        .map((item) => ConnectorItem(
              key: ValueKey(item.id),
              item: item,
              allItems: items,
              onDelete: () => _deleteItem(item.id),
            ))
        .toList();
  }

  List<Widget> _buildLineItems(List<InspirationItemModel> items) {
    return items
        .where((item) => item.type == 'line')
        .map((item) => LineItem(
              key: ValueKey(item.id),
              item: item,
              onDelete: () => _deleteItem(item.id),
              onDataChanged: (data) => _updateData(item.id, data),
            ))
        .toList();
  }

  List<Widget> _buildBoardItems(List<InspirationItemModel> items) {
    return items
        .where((item) =>
            item.type != 'drawing' &&
            item.type != 'line' &&
            item.type != 'connector')
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

      final connectorSource = ref.watch(connectorSourceProvider);
      final isConnectorSource = connectorSource == item.id;

      return Positioned(
        left: item.posX,
        top: item.posY,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            // Blue ring highlight when this item is selected as connector source
            if (isConnectorSource)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF2196F3),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
          ],
        ),
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
    } else if (tool == ToolMode.line) {
      final pos = d.localPosition;
      ref.read(activeLineStartProvider.notifier).state = pos;
      ref.read(activeLineEndProvider.notifier).state = pos;
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
    } else if (tool == ToolMode.line) {
      ref.read(activeLineEndProvider.notifier).state = d.localPosition;
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
    } else if (tool == ToolMode.line) {
      final start = ref.read(activeLineStartProvider);
      final end = ref.read(activeLineEndProvider);
      if (start != null && end != null) {
        final dx = (end.dx - start.dx).abs();
        final dy = (end.dy - start.dy).abs();
        if (dx > 5 || dy > 5) {
          _createLineItem(start.dx, start.dy, end.dx, end.dy);
        }
      }
      ref.read(activeLineStartProvider.notifier).state = null;
      ref.read(activeLineEndProvider.notifier).state = null;
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
      case ToolMode.connector:
        _handleConnectorTap(pos.dx, pos.dy);
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

  Future<void> _createLineItem(double x1, double y1, double x2, double y2) async {
    final brandId = ref.read(currentBrandProvider);
    if (brandId == null) return;

    try {
      final repo = ref.read(inspirationRepositoryProvider);
      final color = ref.read(lineColorProvider);
      final strokeWidth = ref.read(lineStrokeWidthProvider);
      final curved = ref.read(lineCurvedProvider);
      final item = await repo.addItem(
        brandId: brandId,
        posX: 0,
        posY: 0,
        width: 1,
        height: 1,
        type: 'line',
        data: {
          'x1': x1,
          'y1': y1,
          'x2': x2,
          'y2': y2,
          'color': color,
          'strokeWidth': strokeWidth,
          'curved': curved,
          'cx': (x1 + x2) / 2,
          'cy': (y1 + y2) / 2,
        },
      );
      ref.read(boardStateProvider.notifier).addItem(item);
    } catch (e) {
      _showError('Failed to add line: $e');
    }
  }

  void _handleConnectorTap(double x, double y) {
    final sourceId = ref.read(connectorSourceProvider);
    final nearest = _findNearestItem(x, y);

    if (nearest == null) {
      // Clicked empty space — reset
      ref.read(connectorSourceProvider.notifier).state = null;
      return;
    }

    if (sourceId == null) {
      // First tap — select source
      ref.read(connectorSourceProvider.notifier).state = nearest.id;
    } else {
      // Second tap — create connector
      if (nearest.id != sourceId) {
        _createConnector(sourceId, nearest.id);
      }
      ref.read(connectorSourceProvider.notifier).state = null;
    }
  }

  Future<void> _createConnector(String fromId, String toId) async {
    final brandId = ref.read(currentBrandProvider);
    if (brandId == null) return;

    try {
      final repo = ref.read(inspirationRepositoryProvider);
      final color = ref.read(connectorColorProvider);
      final item = await repo.addItem(
        brandId: brandId,
        posX: 0,
        posY: 0,
        width: 1,
        height: 1,
        type: 'connector',
        data: {
          'fromItemId': fromId,
          'toItemId': toId,
          'color': color,
          'strokeWidth': 2.0,
        },
      );
      ref.read(boardStateProvider.notifier).addItem(item);
    } catch (e) {
      _showError('Failed to add connector: $e');
    }
  }

  InspirationItemModel? _findNearestItem(double x, double y) {
    final items = ref.read(boardStateProvider);

    // First: check if tap is inside any item's bounding box (with padding)
    const padding = 10.0;
    for (final item in items) {
      if (item.type == 'drawing' || item.type == 'line' || item.type == 'connector') {
        continue;
      }
      if (x >= item.posX - padding &&
          x <= item.posX + item.width + padding &&
          y >= item.posY - padding &&
          y <= item.posY + item.height + padding) {
        return item;
      }
    }

    // Fallback: nearest center within 120px
    const threshold = 120.0;
    InspirationItemModel? nearest;
    double minDist = double.infinity;
    for (final item in items) {
      if (item.type == 'drawing' || item.type == 'line' || item.type == 'connector') {
        continue;
      }
      final cx = item.posX + item.width / 2;
      final cy = item.posY + item.height / 2;
      final dist = (cx - x) * (cx - x) + (cy - y) * (cy - y);
      if (dist < minDist) {
        minDist = dist;
        nearest = item;
      }
    }
    if (minDist > threshold * threshold) return null;
    return nearest;
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

/// Live preview line while dragging the line tool.
class _LinePreview extends StatelessWidget {
  const _LinePreview({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final start = ref.watch(activeLineStartProvider);
    final end = ref.watch(activeLineEndProvider);
    if (start == null || end == null) return const SizedBox.shrink();

    final color = ref.watch(lineColorProvider);
    final strokeWidth = ref.watch(lineStrokeWidthProvider);
    final clean = color.replaceFirst('#', '');
    final c = clean.length == 6
        ? Color(0xFF000000 | int.parse(clean, radix: 16))
        : const Color(0xFFFFFFFF);

    return CustomPaint(
      painter: _LinePreviewPainter(
        start: start,
        end: end,
        color: c,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _LinePreviewPainter extends CustomPainter {
  _LinePreviewPainter({
    required this.start,
    required this.end,
    required this.color,
    required this.strokeWidth,
  });

  final Offset start;
  final Offset end;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(_LinePreviewPainter old) =>
      old.start != start ||
      old.end != end ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}
