import 'package:flutter/material.dart';

import 'design_tokens.dart';

/// Custom color extension that provides dynamic sidebar and card/surface colors.
///
/// Access via `context.beacon.sidebarBg`, `context.beacon.cardSurface`, etc.
class BeaconColors extends ThemeExtension<BeaconColors> {
  const BeaconColors({
    required this.sidebarBg,
    required this.sidebarSurface,
    required this.sidebarBorder,
    required this.sidebarMuted,
    required this.sidebarText,
    required this.cardBackground,
    required this.cardSurface,
    required this.cardSurfaceMid,
    required this.cardBorder,
  });

  final Color sidebarBg;
  final Color sidebarSurface;
  final Color sidebarBorder;
  final Color sidebarMuted;
  final Color sidebarText;
  final Color cardBackground;
  final Color cardSurface;
  final Color cardSurfaceMid;
  final Color cardBorder;

  /// Derive all companion shades from a sidebar base color and (optional)
  /// card base color using HSL manipulation.
  factory BeaconColors.derive({
    required Color sidebarBase,
    required bool isDark,
    Color? cardBase,
  }) {
    // ── Sidebar derivation (always dark-themed) ──
    final sidebarHsl = HSLColor.fromColor(sidebarBase);
    final sidebarSurface = _adjustLightness(sidebarHsl, 0.05).toColor();
    final sidebarBorder = _adjustLightness(sidebarHsl, 0.08).toColor();
    final sidebarMuted = _adjustLightness(sidebarHsl, 0.30)
        .withSaturation((sidebarHsl.saturation - 0.4).clamp(0.0, 1.0))
        .toColor();
    final sidebarText = sidebarBase.computeLuminance() > 0.4
        ? const Color(0xFF1A1A2E)
        : const Color(0xFFFFFFFF);

    // ── Card/surface derivation ──
    if (isDark && cardBase != null) {
      final cardHsl = HSLColor.fromColor(cardBase);
      final cardBackground = _adjustLightness(cardHsl, -0.04).toColor();
      final cardSurfaceMid = _adjustLightness(cardHsl, 0.05).toColor();
      final cardBorder = _adjustLightness(cardHsl, 0.08).toColor();

      return BeaconColors(
        sidebarBg: sidebarBase,
        sidebarSurface: sidebarSurface,
        sidebarBorder: sidebarBorder,
        sidebarMuted: sidebarMuted,
        sidebarText: sidebarText,
        cardBackground: cardBackground,
        cardSurface: cardBase,
        cardSurfaceMid: cardSurfaceMid,
        cardBorder: cardBorder,
      );
    }

    // Light mode or no custom card color — use default tokens
    return BeaconColors(
      sidebarBg: sidebarBase,
      sidebarSurface: sidebarSurface,
      sidebarBorder: sidebarBorder,
      sidebarMuted: sidebarMuted,
      sidebarText: sidebarText,
      cardBackground:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      cardSurface: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      cardSurfaceMid:
          isDark ? AppColors.surfaceMidDark : AppColors.surfaceMidLight,
      cardBorder: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }

  static HSLColor _adjustLightness(HSLColor hsl, double delta) {
    return hsl.withLightness((hsl.lightness + delta).clamp(0.0, 1.0));
  }

  @override
  BeaconColors copyWith({
    Color? sidebarBg,
    Color? sidebarSurface,
    Color? sidebarBorder,
    Color? sidebarMuted,
    Color? sidebarText,
    Color? cardBackground,
    Color? cardSurface,
    Color? cardSurfaceMid,
    Color? cardBorder,
  }) {
    return BeaconColors(
      sidebarBg: sidebarBg ?? this.sidebarBg,
      sidebarSurface: sidebarSurface ?? this.sidebarSurface,
      sidebarBorder: sidebarBorder ?? this.sidebarBorder,
      sidebarMuted: sidebarMuted ?? this.sidebarMuted,
      sidebarText: sidebarText ?? this.sidebarText,
      cardBackground: cardBackground ?? this.cardBackground,
      cardSurface: cardSurface ?? this.cardSurface,
      cardSurfaceMid: cardSurfaceMid ?? this.cardSurfaceMid,
      cardBorder: cardBorder ?? this.cardBorder,
    );
  }

  @override
  BeaconColors lerp(BeaconColors? other, double t) {
    if (other is! BeaconColors) return this;
    return BeaconColors(
      sidebarBg: Color.lerp(sidebarBg, other.sidebarBg, t)!,
      sidebarSurface: Color.lerp(sidebarSurface, other.sidebarSurface, t)!,
      sidebarBorder: Color.lerp(sidebarBorder, other.sidebarBorder, t)!,
      sidebarMuted: Color.lerp(sidebarMuted, other.sidebarMuted, t)!,
      sidebarText: Color.lerp(sidebarText, other.sidebarText, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      cardSurfaceMid: Color.lerp(cardSurfaceMid, other.cardSurfaceMid, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
    );
  }
}

extension BeaconColorsX on BuildContext {
  BeaconColors get beacon => Theme.of(this).extension<BeaconColors>()!;
}
