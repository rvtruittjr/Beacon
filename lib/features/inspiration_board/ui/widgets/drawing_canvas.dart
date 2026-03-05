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

    final pts = stroke.points;
    final path = Path();
    path.moveTo(pts.first.x, pts.first.y);

    if (pts.length == 2) {
      path.lineTo(pts[1].x, pts[1].y);
    } else {
      // Use quadratic bezier curves through midpoints for smooth lines
      for (var i = 1; i < pts.length - 1; i++) {
        final midX = (pts[i].x + pts[i + 1].x) / 2;
        final midY = (pts[i].y + pts[i + 1].y) / 2;
        path.quadraticBezierTo(pts[i].x, pts[i].y, midX, midY);
      }
      // Connect to the last point
      final last = pts.last;
      path.lineTo(last.x, last.y);
    }

    canvas.drawPath(path, paint);
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
