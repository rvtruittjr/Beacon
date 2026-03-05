import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/design_tokens.dart';
import '../../models/board_item_type.dart';
import '../../models/inspiration_item_model.dart';
import '../../providers/tool_state_provider.dart';

class ShapeItem extends ConsumerStatefulWidget {
  const ShapeItem({
    super.key,
    required this.item,
    required this.onMoved,
    required this.onDragEnd,
    required this.onResized,
    required this.onResizeEnd,
    required this.onDelete,
  });

  final InspirationItemModel item;
  final void Function(double dx, double dy) onMoved;
  final VoidCallback onDragEnd;
  final void Function(double dw, double dh) onResized;
  final VoidCallback onResizeEnd;
  final VoidCallback onDelete;

  @override
  ConsumerState<ShapeItem> createState() => _ShapeItemState();
}

class _ShapeItemState extends ConsumerState<ShapeItem> {
  bool _hovered = false;

  ShapeType get _shapeType =>
      ShapeType.fromString(widget.item.data['shapeType'] as String? ?? 'rectangle');
  String get _fillHex => widget.item.data['fillColor'] as String? ?? '#6C63FF';
  String get _strokeHex =>
      widget.item.data['strokeColor'] as String? ?? '#FFFFFF';
  double get _strokeWidth =>
      (widget.item.data['strokeWidth'] as num?)?.toDouble() ?? 2.0;

  Color _hexToColor(String hex) {
    final clean = hex.replaceFirst('#', '');
    if (clean.length == 6) {
      return Color(0xFF000000 | int.parse(clean, radix: 16));
    }
    return const Color(0xFF6C63FF);
  }

  bool get _showHandles {
    final selected = ref.watch(selectedItemProvider);
    return _hovered || selected == widget.item.id;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onPanUpdate: (d) => widget.onMoved(d.delta.dx, d.delta.dy),
        onPanEnd: (_) => widget.onDragEnd(),
        child: SizedBox(
          width: widget.item.width,
          height: widget.item.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(widget.item.width, widget.item.height),
                painter: _ShapePainter(
                  shapeType: _shapeType,
                  fillColor: _hexToColor(_fillHex),
                  strokeColor: _hexToColor(_strokeHex),
                  strokeWidth: _strokeWidth,
                ),
              ),
              // Selection border
              if (_showHandles)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: primary, width: 2),
                        borderRadius: BorderRadius.all(AppRadius.md),
                      ),
                    ),
                  ),
                ),
              if (_showHandles)
                Positioned(
                  top: -4,
                  right: -4,
                  child: GestureDetector(
                    onTap: widget.onDelete,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              if (_showHandles)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (d) =>
                        widget.onResized(d.delta.dx, d.delta.dy),
                    onPanEnd: (_) => widget.onResizeEnd(),
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.9),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                            ),
                          ),
                          child: const Icon(Icons.drag_handle,
                              size: 10, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  _ShapePainter({
    required this.shapeType,
    required this.fillColor,
    required this.strokeColor,
    required this.strokeWidth,
  });

  final ShapeType shapeType;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    switch (shapeType) {
      case ShapeType.rectangle:
        final rect = Rect.fromLTWH(
          strokeWidth / 2,
          strokeWidth / 2,
          size.width - strokeWidth,
          size.height - strokeWidth,
        );
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
        canvas.drawRRect(rrect, fillPaint);
        canvas.drawRRect(rrect, strokePaint);

      case ShapeType.circle:
        final center = Offset(size.width / 2, size.height / 2);
        final radius =
            math.min(size.width, size.height) / 2 - strokeWidth / 2;
        canvas.drawCircle(center, radius, fillPaint);
        canvas.drawCircle(center, radius, strokePaint);

      case ShapeType.line:
        canvas.drawLine(
          Offset(0, size.height / 2),
          Offset(size.width, size.height / 2),
          strokePaint,
        );

      case ShapeType.arrow:
        final start = Offset(0, size.height / 2);
        final end = Offset(size.width, size.height / 2);
        canvas.drawLine(start, end, strokePaint);
        final headSize = math.min(16.0, size.width * 0.2);
        final path = Path()
          ..moveTo(end.dx, end.dy)
          ..lineTo(end.dx - headSize, end.dy - headSize * 0.5)
          ..lineTo(end.dx - headSize, end.dy + headSize * 0.5)
          ..close();
        canvas.drawPath(
          path,
          Paint()
            ..color = strokeColor
            ..style = PaintingStyle.fill,
        );
    }
  }

  @override
  bool shouldRepaint(_ShapePainter old) =>
      old.shapeType != shapeType ||
      old.fillColor != fillColor ||
      old.strokeColor != strokeColor ||
      old.strokeWidth != strokeWidth;
}
