import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/config/design_tokens.dart';
import '../../models/inspiration_item_model.dart';

/// Renders a straight line or bezier curve stored as a board item.
/// Data schema: {x1, y1, x2, y2, color, strokeWidth, curved, cx, cy}
/// The item's posX/posY are always 0,0 — actual coordinates are in data.
class LineItem extends StatefulWidget {
  const LineItem({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onDataChanged,
  });

  final InspirationItemModel item;
  final VoidCallback onDelete;
  final void Function(Map<String, dynamic> data) onDataChanged;

  @override
  State<LineItem> createState() => _LineItemState();
}

class _LineItemState extends State<LineItem> {
  bool _hovered = false;

  double get _x1 => (widget.item.data['x1'] as num?)?.toDouble() ?? 0;
  double get _y1 => (widget.item.data['y1'] as num?)?.toDouble() ?? 0;
  double get _x2 => (widget.item.data['x2'] as num?)?.toDouble() ?? 100;
  double get _y2 => (widget.item.data['y2'] as num?)?.toDouble() ?? 100;
  double get _cx => (widget.item.data['cx'] as num?)?.toDouble() ?? (_x1 + _x2) / 2;
  double get _cy => (widget.item.data['cy'] as num?)?.toDouble() ?? (_y1 + _y2) / 2;
  bool get _curved => widget.item.data['curved'] == true;
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

  // Bounding box for the line (with padding for handles)
  double get _minX => [_x1, _x2, if (_curved) _cx].reduce(math.min) - 12;
  double get _minY => [_y1, _y2, if (_curved) _cy].reduce(math.min) - 12;
  double get _maxX => [_x1, _x2, if (_curved) _cx].reduce(math.max) + 12;
  double get _maxY => [_y1, _y2, if (_curved) _cy].reduce(math.max) + 12;

  void _updateEndpoint(String key, double x, double y) {
    widget.onDataChanged({
      ...widget.item.data,
      key == 'p1' ? 'x1' : (key == 'p2' ? 'x2' : 'cx'):
          key == 'p1' ? x : (key == 'p2' ? x : x),
      key == 'p1' ? 'y1' : (key == 'p2' ? 'y2' : 'cy'):
          key == 'p1' ? y : (key == 'p2' ? y : y),
    });
  }

  void _moveEndpoint(String key, double dx, double dy) {
    final data = {...widget.item.data};
    if (key == 'p1') {
      data['x1'] = _x1 + dx;
      data['y1'] = _y1 + dy;
    } else if (key == 'p2') {
      data['x2'] = _x2 + dx;
      data['y2'] = _y2 + dy;
    } else {
      data['cx'] = _cx + dx;
      data['cy'] = _cy + dy;
    }
    widget.onDataChanged(data);
  }

  @override
  Widget build(BuildContext context) {
    final w = _maxX - _minX;
    final h = _maxY - _minY;

    return Positioned(
      left: _minX,
      top: _minY,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: SizedBox(
          width: w,
          height: h,
          child: Stack(
            children: [
              // Line painting
              CustomPaint(
                size: Size(w, h),
                painter: _LinePainter(
                  x1: _x1 - _minX,
                  y1: _y1 - _minY,
                  x2: _x2 - _minX,
                  y2: _y2 - _minY,
                  cx: _cx - _minX,
                  cy: _cy - _minY,
                  color: _color,
                  strokeWidth: _strokeWidth,
                  curved: _curved,
                ),
              ),

              // Endpoint handles (on hover)
              if (_hovered) ...[
                _DragHandle(
                  x: _x1 - _minX,
                  y: _y1 - _minY,
                  onDrag: (dx, dy) => _moveEndpoint('p1', dx, dy),
                ),
                _DragHandle(
                  x: _x2 - _minX,
                  y: _y2 - _minY,
                  onDrag: (dx, dy) => _moveEndpoint('p2', dx, dy),
                ),
                if (_curved)
                  _DragHandle(
                    x: _cx - _minX,
                    y: _cy - _minY,
                    onDrag: (dx, dy) => _moveEndpoint('ctrl', dx, dy),
                    isCurveHandle: true,
                  ),
                // Delete button at midpoint
                Positioned(
                  left: ((_x1 + _x2) / 2 - _minX) - 11,
                  top: ((_y1 + _y2) / 2 - _minY) - 22,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle({
    required this.x,
    required this.y,
    required this.onDrag,
    this.isCurveHandle = false,
  });

  final double x;
  final double y;
  final void Function(double dx, double dy) onDrag;
  final bool isCurveHandle;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final size = isCurveHandle ? 10.0 : 12.0;

    return Positioned(
      left: x - size / 2,
      top: y - size / 2,
      child: GestureDetector(
        onPanUpdate: (d) => onDrag(d.delta.dx, d.delta.dy),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: isCurveHandle ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: isCurveHandle ? BorderRadius.all(Radius.circular(3)) : null,
            border: Border.all(color: primary, width: 2),
          ),
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.cx,
    required this.cy,
    required this.color,
    required this.strokeWidth,
    required this.curved,
  });

  final double x1, y1, x2, y2, cx, cy;
  final Color color;
  final double strokeWidth;
  final bool curved;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    if (curved) {
      final path = Path()
        ..moveTo(x1, y1)
        ..quadraticBezierTo(cx, cy, x2, y2);
      canvas.drawPath(path, paint);
    } else {
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.x1 != x1 ||
      old.y1 != y1 ||
      old.x2 != x2 ||
      old.y2 != y2 ||
      old.cx != cx ||
      old.cy != cy ||
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.curved != curved;
}
