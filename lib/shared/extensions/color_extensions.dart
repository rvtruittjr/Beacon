import 'package:flutter/material.dart';

extension ColorExtension on Color {
  String toHex() => '#${value.toRadixString(16).substring(2).toUpperCase()}';
  static Color fromHex(String hex) {
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}
