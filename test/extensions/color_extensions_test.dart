import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:beakon/shared/extensions/color_extensions.dart';

void main() {
  group('toHex', () {
    test('converts color to hex string', () {
      const color = Color(0xFFFF5733);
      expect(color.toHex(), equals('#FF5733'));
    });

    test('converts white to hex', () {
      const color = Color(0xFFFFFFFF);
      expect(color.toHex(), equals('#FFFFFF'));
    });

    test('converts black to hex', () {
      const color = Color(0xFF000000);
      expect(color.toHex(), equals('#000000'));
    });
  });

  group('fromHex', () {
    test('parses hex with hash', () {
      final color = ColorExtension.fromHex('#FF5733');
      expect(color, equals(const Color(0xFFFF5733)));
    });

    test('parses hex without hash', () {
      final color = ColorExtension.fromHex('6C63FF');
      expect(color, equals(const Color(0xFF6C63FF)));
    });
  });
}
