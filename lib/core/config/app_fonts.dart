import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  AppFonts._();

  static TextStyle clashDisplay({
    double fontSize = 48,
    FontWeight fontWeight = FontWeight.w800,
    Color? color,
    double? height,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height ?? 1.1,
      letterSpacing: -0.5,
    );
  }

  static TextStyle caveat({
    double fontSize = 40,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
  }) {
    return GoogleFonts.caveat(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle inter({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height ?? 1.6,
    );
  }
}
