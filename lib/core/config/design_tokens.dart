import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Dark mode base
  static const backgroundDark  = Color(0xFF121218);
  static const surfaceDark     = Color(0xFF1C1C26);
  static const surfaceMidDark  = Color(0xFF252530);
  static const borderDark      = Color(0xFF2E2E3C);
  static const mutedDark       = Color(0xFF6B6B80);
  static const textPrimaryDark = Color(0xFFF2F2F8);

  // ── Light mode base (soft lavender-gray)
  static const backgroundLight  = Color(0xFFF0EEFA);
  static const surfaceLight     = Color(0xFFFFFFFF);
  static const surfaceMidLight  = Color(0xFFF5F4FB);
  static const borderLight      = Color(0xFFE2E0EE);
  static const mutedLight       = Color(0xFF8E8EA0);
  static const textPrimaryLight = Color(0xFF1A1A2E);

  // ── Sidebar (always dark, floats on background)
  static const sidebarBg       = Color(0xFF1A1A2E);
  static const sidebarSurface  = Color(0xFF252540);
  static const sidebarBorder   = Color(0xFF2F2F4A);
  static const sidebarMuted    = Color(0xFF7878A0);
  static const sidebarText     = Color(0xFFFFFFFF);

  // ── Accent colors
  static const blockViolet = Color(0xFF6C63FF);
  static const blockCoral  = Color(0xFFFF6B6B);
  static const blockLime   = Color(0xFFC8F135);
  static const blockYellow = Color(0xFFFFD166);

  // ── Functional
  static const focusRing = Color(0xFF6C63FF);
  static const success   = Color(0xFF22C55E);
  static const warning   = Color(0xFFF59E0B);
  static const error     = Color(0xFFEF4444);

  // ── Text on accent colors
  static const textOnLime   = Color(0xFF1A1A2E);
  static const textOnYellow = Color(0xFF1A1A2E);
  static const textOnViolet = Color(0xFFFFFFFF);
  static const textOnCoral  = Color(0xFFFFFFFF);
}

class AppSpacing {
  AppSpacing._();
  static const xs  = 4.0;
  static const sm  = 8.0;
  static const md  = 16.0;
  static const lg  = 24.0;
  static const xl  = 32.0;
  static const x2l = 48.0;
  static const x3l = 64.0;
}

class AppRadius {
  AppRadius._();
  static const xs   = Radius.circular(4.0);
  static const sm   = Radius.circular(8.0);
  static const md   = Radius.circular(12.0);
  static const lg   = Radius.circular(16.0);
  static const xl   = Radius.circular(20.0);
  static const x2l  = Radius.circular(24.0);
  static const full = Radius.circular(999.0);
  static const xsValue   = 4.0;
  static const smValue   = 8.0;
  static const mdValue   = 12.0;
  static const lgValue   = 16.0;
  static const xlValue   = 20.0;
  static const x2lValue  = 24.0;
  static const fullValue = 999.0;
}

class AppShadows {
  AppShadows._();

  static const sm = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const md = [
    BoxShadow(
      color: Color(0x0C000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x04000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const lg = [
    BoxShadow(
      color: Color(0x10000000),
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x06000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const card = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];
}

class AppDurations {
  AppDurations._();
  static const micro       = Duration(milliseconds: 120);
  static const fast        = Duration(milliseconds: 200);
  static const normal      = Duration(milliseconds: 250);
  static const medium      = Duration(milliseconds: 280);
  static const slow        = Duration(milliseconds: 300);
  static const chart       = Duration(milliseconds: 400);
  static const stagger     = Duration(milliseconds: 350);
  static const celebration = Duration(milliseconds: 500);
  static const floater     = Duration(milliseconds: 3500);
}
