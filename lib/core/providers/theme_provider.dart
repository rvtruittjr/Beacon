// ignore_for_file: deprecated_member_use
import 'dart:html' show window;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(_loadFromStorage());

  static ThemeMode _loadFromStorage() {
    final stored = window.localStorage['theme_mode'];
    return switch (stored) {
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };
  }

  void toggle() {
    final next = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setMode(next);
  }

  void setMode(ThemeMode mode) {
    state = mode;
    window.localStorage['theme_mode'] = mode.name;
  }
}
