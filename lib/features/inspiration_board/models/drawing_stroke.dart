class DrawingPoint {
  final double x;
  final double y;

  const DrawingPoint(this.x, this.y);

  factory DrawingPoint.fromJson(Map<String, dynamic> json) =>
      DrawingPoint((json['x'] as num).toDouble(), (json['y'] as num).toDouble());

  Map<String, dynamic> toJson() => {'x': x, 'y': y};
}

class DrawingStroke {
  final List<DrawingPoint> points;
  final String colorHex;
  final double strokeWidth;

  const DrawingStroke({
    required this.points,
    this.colorHex = '#FFFFFF',
    this.strokeWidth = 3.0,
  });

  factory DrawingStroke.fromJson(Map<String, dynamic> json) => DrawingStroke(
        points: (json['points'] as List)
            .map((p) => DrawingPoint.fromJson(p as Map<String, dynamic>))
            .toList(),
        colorHex: json['color'] as String? ?? '#FFFFFF',
        strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 3.0,
      );

  Map<String, dynamic> toJson() => {
        'points': points.map((p) => p.toJson()).toList(),
        'color': colorHex,
        'strokeWidth': strokeWidth,
      };
}
