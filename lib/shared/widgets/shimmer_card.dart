import 'package:flutter/material.dart';

import '../../core/config/design_tokens.dart';

/// A shimmer placeholder card for loading states.
class ShimmerCard extends StatefulWidget {
  const ShimmerCard({super.key, this.aspectRatio = 0.85});
  final double aspectRatio;

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? AppColors.surfaceMidDark : AppColors.surfaceMidLight;
    final highlightColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(AppRadius.lg),
              gradient: LinearGradient(
                begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
                end: Alignment(1.0 + 2.0 * _controller.value, 0),
                colors: [baseColor, highlightColor, baseColor],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A grid of shimmer placeholders for loading states.
class ShimmerGrid extends StatelessWidget {
  const ShimmerGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 3,
    this.aspectRatio = 0.85,
  });

  final int itemCount;
  final int crossAxisCount;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: aspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) =>
          ShimmerCard(aspectRatio: aspectRatio),
    );
  }
}
