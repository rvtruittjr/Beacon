import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/config/design_tokens.dart';
import '../../models/inspiration_item_model.dart';

/// Draws an arrow between two board items, auto-updating when they move.
/// Data schema: {fromItemId, toItemId, color, strokeWidth}
class ConnectorItem extends StatefulWidget {
  const ConnectorItem({
    super.key,
    required this.item,
    required this.allItems,
    required this.onDelete,
  });

  final InspirationItemModel item;
  final List<InspirationItemModel> allItems;
  final VoidCallback onDelete;

  @override
  State<ConnectorItem> createState() => _ConnectorItemState();
}

class _ConnectorItemState extends State<ConnectorItem> {
  bool _hovered = false;

  String get _fromId => widget.item.data['fromItemId'] as String? ?? '';
  String get _toId => widget.item.data['toItemId'] as String? ?? '';
  String get _colorHex => widget.item.data['color'] as String? ?? '#FFFFFF';
  double get _strokeWidth =>
      (widget.item.data['strokeWidth'] as num?)?.toDouble() ?? 2.0;

  Color get _color {
    final clean = _colorHex.replaceFirst('#', '');
    if (clean.length == 6) {
      return Color(0xFF000000 | int.parse(clean, radix: 16));
    }
    return const Color(0xFFFFFFFF);
  }

  InspirationItemModel? _findItem(String id) {
    for (final item in widget.allItems) {
      if (item.id == id) return item;
    }
    return null;
  }

  Offset _centerOf(InspirationItemModel item) {
    return Offset(
      item.posX + item.width / 2,
      item.posY + item.height / 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final from = _findItem(_fromId);
    final to = _findItem(_toId);
    if (from == null || to == null) return const SizedBox.shrink();

    final start = _centerOf(from);
    final end = _centerOf(to);

    final minX = math.min(start.dx, end.dx) - 20;
    final minY = math.min(start.dy, end.dy) - 20;
    final maxX = math.max(start.dx, end.dx) + 20;
    final maxY = math.max(start.dy, end.dy) + 20;

    return Positioned(
      left: minX,
      top: minY,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: SizedBox(
          width: maxX - minX,
          height: maxY - minY,
          child: Stack(
            children: [
              CustomPaint(
                size: Size(maxX - minX, maxY - minY),
                painter: _ConnectorPainter(
                  x1: start.dx - minX,
                  y1: start.dy - minY,
                  x2: end.dx - minX,
                  y2: end.dy - minY,
                  color: _color,
                  strokeWidth: _strokeWidth,
                ),
              ),
              if (_hovered)
                Positioned(
                  left: ((start.dx + end.dx) / 2 - minX) - 11,
                  top: ((start.dy + end.dy) / 2 - minY) - 11,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.color,
    required this.strokeWidth,
  });

  final double x1, y1, x2, y2;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    // Draw the line
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);

    // Draw arrowhead at the end
    final angle = math.atan2(y2 - y1, x2 - x1);
    final headSize = math.max(10.0, strokeWidth * 4);
    final path = Path()
      ..moveTo(x2, y2)
      ..lineTo(
        x2 - headSize * math.cos(angle - 0.4),
        y2 - headSize * math.sin(angle - 0.4),
      )
      ..lineTo(
        x2 - headSize * math.cos(angle + 0.4),
        y2 - headSize * math.sin(angle + 0.4),
      )
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_ConnectorPainter old) =>
      old.x1 != x1 ||
      old.y1 != y1 ||
      old.x2 != x2 ||
      old.y2 != y2 ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}
