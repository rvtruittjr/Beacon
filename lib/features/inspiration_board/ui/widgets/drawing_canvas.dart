import 'package:flutter/material.dart';

import '../../models/drawing_stroke.dart';

class DrawingCanvas extends CustomPainter {
  DrawingCanvas({
    required this.strokes,
    this.activeStroke,
  });

  final List<DrawingStroke> strokes;
  final DrawingStroke? activeStroke;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _paintStroke(canvas, stroke);
    }
    if (activeStroke != null) {
      _paintStroke(canvas, activeStroke!);
    }
  }

  void _paintStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.length < 2) return;

    final paint = Paint()
      ..color = _hexToColor(stroke.colorHex)
      ..strokeWidth = stroke.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    // Smooth points first, then build bezier path
    final pts = _smooth(stroke.points);
    final path = Path();
    path.moveTo(pts.first.x, pts.first.y);

    if (pts.length == 2) {
      path.lineTo(pts[1].x, pts[1].y);
    } else {
      // Quadratic bezier curves through midpoints
      for (var i = 1; i < pts.length - 1; i++) {
        final midX = (pts[i].x + pts[i + 1].x) / 2;
        final midY = (pts[i].y + pts[i + 1].y) / 2;
        path.quadraticBezierTo(pts[i].x, pts[i].y, midX, midY);
      }
      path.lineTo(pts.last.x, pts.last.y);
    }

    canvas.drawPath(path, paint);
  }

  /// Moving-average smooth pass — averages each point with its neighbors.
  static List<DrawingPoint> _smooth(List<DrawingPoint> raw) {
    if (raw.length < 5) return raw;

    final result = <DrawingPoint>[raw.first];
    for (var i = 1; i < raw.length - 1; i++) {
      // Weighted average: 25% prev, 50% current, 25% next
      final x = raw[i - 1].x * 0.25 + raw[i].x * 0.5 + raw[i + 1].x * 0.25;
      final y = raw[i - 1].y * 0.25 + raw[i].y * 0.5 + raw[i + 1].y * 0.25;
      result.add(DrawingPoint(x, y));
    }
    result.add(raw.last);

    // Second pass for extra smoothness
    if (result.length < 5) return result;
    final result2 = <DrawingPoint>[result.first];
    for (var i = 1; i < result.length - 1; i++) {
      final x =
          result[i - 1].x * 0.25 + result[i].x * 0.5 + result[i + 1].x * 0.25;
      final y =
          result[i - 1].y * 0.25 + result[i].y * 0.5 + result[i + 1].y * 0.25;
      result2.add(DrawingPoint(x, y));
    }
    result2.add(result.last);

    return result2;
  }

  static Color _hexToColor(String hex) {
    final clean = hex.replaceFirst('#', '');
    if (clean.length == 6) {
      return Color(0xFF000000 | int.parse(clean, radix: 16));
    }
    return const Color(0xFFFFFFFF);
  }

  @override
  bool shouldRepaint(DrawingCanvas oldDelegate) =>
      oldDelegate.strokes != strokes || oldDelegate.activeStroke != activeStroke;
}
