// ignore_for_file: deprecated_member_use
import 'dart:html' show window;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/design_tokens.dart';

// ── Theme Mode ─────────────────────────────────────────────────

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

// ── Accent Color ───────────────────────────────────────────────

final accentColorProvider =
    StateNotifierProvider<AccentColorNotifier, Color>((ref) {
  return AccentColorNotifier();
});

class AccentColorNotifier extends StateNotifier<Color> {
  AccentColorNotifier() : super(_loadFromStorage());

  static Color _loadFromStorage() {
    final stored = window.localStorage['accent_color'];
    if (stored != null && stored.length == 7 && stored.startsWith('#')) {
      try {
        return Color(int.parse('FF${stored.substring(1)}', radix: 16));
      } catch (_) {}
    }
    return AppColors.blockLime;
  }

  void setColor(Color color) {
    state = color;
    final hex = color.value.toRadixString(16).padLeft(8, '0').substring(2);
    window.localStorage['accent_color'] = '#$hex';
  }

  void reset() => setColor(AppColors.blockLime);

  /// Compute contrasting text color for any accent.
  static Color textOnColor(Color color) {
    return color.computeLuminance() > 0.4
        ? const Color(0xFF1A1A2E)
        : const Color(0xFFFFFFFF);
  }
}

// ── Sidebar Color ─────────────────────────────────────────────

final sidebarColorProvider =
    StateNotifierProvider<SidebarColorNotifier, Color>((ref) {
  return SidebarColorNotifier();
});

class SidebarColorNotifier extends StateNotifier<Color> {
  SidebarColorNotifier() : super(_loadFromStorage());

  static Color _loadFromStorage() {
    final stored = window.localStorage['sidebar_color'];
    if (stored != null && stored.length == 7 && stored.startsWith('#')) {
      try {
        return Color(int.parse('FF${stored.substring(1)}', radix: 16));
      } catch (_) {}
    }
    return AppColors.sidebarBg;
  }

  void setColor(Color color) {
    state = color;
    final hex = color.value.toRadixString(16).padLeft(8, '0').substring(2);
    window.localStorage['sidebar_color'] = '#$hex';
  }

  void reset() => setColor(AppColors.sidebarBg);
}

// ── Card Color ────────────────────────────────────────────────

final cardColorProvider =
    StateNotifierProvider<CardColorNotifier, Color>((ref) {
  return CardColorNotifier();
});

class CardColorNotifier extends StateNotifier<Color> {
  CardColorNotifier() : super(_loadFromStorage());

  static Color _loadFromStorage() {
    final stored = window.localStorage['card_color'];
    if (stored != null && stored.length == 7 && stored.startsWith('#')) {
      try {
        return Color(int.parse('FF${stored.substring(1)}', radix: 16));
      } catch (_) {}
    }
    return AppColors.surfaceDark;
  }

  void setColor(Color color) {
    state = color;
    final hex = color.value.toRadixString(16).padLeft(8, '0').substring(2);
    window.localStorage['card_color'] = '#$hex';
  }

  void reset() => setColor(AppColors.surfaceDark);
}
