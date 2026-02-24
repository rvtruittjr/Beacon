import 'package:flutter/material.dart';

class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.desktop,
    required this.mobile,
    this.breakpoint = 768,
  });

  final Widget desktop;
  final Widget mobile;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > breakpoint) {
          return desktop;
        }
        return mobile;
      },
    );
  }
}
