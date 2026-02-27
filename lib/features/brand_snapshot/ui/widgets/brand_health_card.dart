import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/config/beacon_colors.dart';
import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../models/brand_health_score.dart';

class BrandHealthCard extends StatelessWidget {
  const BrandHealthCard({super.key, required this.score});
  final BrandHealthScore score;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 600;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.beacon.sidebarBg,
        borderRadius: BorderRadius.all(AppRadius.xl),
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildCircle(context),
                const SizedBox(width: AppSpacing.x2l),
                Expanded(child: _buildChecklist(context)),
              ],
            )
          : Column(
              children: [
                _buildCircle(context),
                const SizedBox(height: AppSpacing.lg),
                _buildChecklist(context),
              ],
            ),
    );
  }

  Widget _buildCircle(BuildContext context) {
    final targetProgress = score.totalScore / 100;
    final progressColor = score.totalScore < 40
        ? AppColors.blockCoral
        : score.totalScore < 70
            ? AppColors.blockYellow
            : AppColors.blockLime;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: targetProgress),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, progress, _) {
        final displayScore = (progress * 100).round();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: _HealthArcPainter(
                  progress: progress,
                  trackColor: context.beacon.sidebarSurface,
                  progressColor: progressColor,
                ),
                child: Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$displayScore',
                          style: AppFonts.clashDisplay(
                            fontSize: 36,
                            color: context.beacon.sidebarText,
                          ),
                        ),
                        TextSpan(
                          text: '%',
                          style: AppFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.beacon.sidebarMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Brand Health',
              style: AppFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.beacon.sidebarMuted,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChecklist(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < score.sections.length; i++)
          _ChecklistRow(
            section: score.sections[i],
            delay: Duration(milliseconds: 80 * i),
          ),
      ],
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.section, required this.delay});
  final BrandHealthSection section;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        section.isComplete ? AppColors.success : context.beacon.sidebarMuted;
    final icon = section.isComplete ? LucideIcons.checkCircle2 : LucideIcons.circle;
    final textColor =
        section.isComplete ? context.beacon.sidebarText : context.beacon.sidebarMuted;

    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              section.label,
              style: AppFonts.inter(
                fontSize: 14,
                fontWeight: section.isComplete ? FontWeight.w500 : FontWeight.w400,
                color: textColor,
              ),
            ),
          ),
          if (!section.isComplete)
            Icon(
              LucideIcons.chevronRight,
              size: 14,
              color: context.beacon.sidebarMuted,
            ),
        ],
      ),
    );

    if (section.isComplete) return row;

    return GestureDetector(
      onTap: () => context.go(section.routePath),
      behavior: HitTestBehavior.opaque,
      child: row,
    );
  }
}

class _HealthArcPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _HealthArcPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    this.strokeWidth = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - strokeWidth / 2;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (progress > 0) {
      final sweepAngle = 2 * pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweepAngle,
        false,
        Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HealthArcPainter old) =>
      old.progress != progress || old.progressColor != progressColor;
}
