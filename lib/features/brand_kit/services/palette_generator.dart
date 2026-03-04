import 'package:flutter/material.dart';

/// Pure color-theory palette generator using HSL math.
class PaletteGenerator {
  PaletteGenerator._();

  static Map<String, List<Color>> generate(Color primary) {
    final hsl = HSLColor.fromColor(primary);
    return {
      'Complementary': [primary, _rotate(hsl, 180)],
      'Analogous': [_rotate(hsl, -30), primary, _rotate(hsl, 30)],
      'Triadic': [primary, _rotate(hsl, 120), _rotate(hsl, 240)],
      'Split-Complementary': [primary, _rotate(hsl, 150), _rotate(hsl, 210)],
      'Monochromatic': _monochromatic(hsl),
    };
  }

  static Color _rotate(HSLColor hsl, double degrees) {
    return hsl
        .withHue((hsl.hue + degrees) % 360)
        .toColor();
  }

  static List<Color> _monochromatic(HSLColor hsl) {
    return [
      hsl.withLightness((hsl.lightness * 0.3).clamp(0.0, 1.0)).toColor(),
      hsl.withLightness((hsl.lightness * 0.6).clamp(0.0, 1.0)).toColor(),
      hsl.toColor(),
      hsl.withLightness((hsl.lightness * 1.3).clamp(0.0, 1.0)).toColor(),
      hsl.withLightness((hsl.lightness * 1.6).clamp(0.0, 1.0)).toColor(),
    ];
  }
}
