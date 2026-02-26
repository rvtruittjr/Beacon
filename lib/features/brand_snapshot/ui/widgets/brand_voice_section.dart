import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../shared/widgets/app_card.dart';

class BrandVoiceSection extends StatelessWidget {
  const BrandVoiceSection({super.key, required this.voice});
  final Map<String, dynamic>? voice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return AppCard(
      variant: AppCardVariant.feature,
      blockColor: AppColors.blockLime,
      headerTitle: 'Voice & Tone',
      child: voice == null
          ? _buildEmpty(context, mutedColor)
          : _buildContent(context, textColor, mutedColor),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Color textColor,
    Color mutedColor,
  ) {
    final archetype = voice!['archetype'] as String?;
    final mission = voice!['mission_statement'] as String?;
    final formal = (voice!['tone_formal'] as num?)?.toInt() ?? 5;
    final serious = (voice!['tone_serious'] as num?)?.toInt() ?? 5;
    final bold = (voice!['tone_bold'] as num?)?.toInt() ?? 5;

    final leftColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (archetype != null && archetype.isNotEmpty)
          Text(
            archetype,
            style: AppFonts.clashDisplay(
              fontSize: 24,
              color: textColor,
            ),
          ),
        if (mission != null && mission.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.only(left: AppSpacing.md),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: AppColors.blockLime,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              mission,
              style: AppFonts.inter(
                fontSize: 14,
                color: mutedColor,
              ).copyWith(fontStyle: FontStyle.italic),
            ),
          ),
        ],
        if (archetype == null && mission == null)
          Text(
            'Set your voice archetype and mission statement.',
            style: AppFonts.inter(
              fontSize: 14,
              color: mutedColor,
            ).copyWith(fontStyle: FontStyle.italic),
          ),
      ],
    );

    final chart = SizedBox(
      height: 200,
      child: _ToneRadarChart(
        formal: formal,
        serious: serious,
        bold: bold,
      ),
    );

    // Use MediaQuery instead of LayoutBuilder to avoid IntrinsicHeight conflict
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth > 1100;

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: leftColumn),
          const SizedBox(width: AppSpacing.lg),
          SizedBox(width: 220, child: chart),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leftColumn,
        const SizedBox(height: AppSpacing.lg),
        chart,
      ],
    );
  }

  Widget _buildEmpty(BuildContext context, Color mutedColor) {
    return Row(
      children: [
        Text(
          'No voice profile set yet.',
          style: AppFonts.inter(fontSize: 14, color: mutedColor)
              .copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(width: AppSpacing.sm),
        TextButton(
          onPressed: () => context.go('/app/voice'),
          child: Text(
            'Add',
            style: AppFonts.inter(fontSize: 14, color: mutedColor),
          ),
        ),
      ],
    );
  }
}

class _ToneRadarChart extends StatelessWidget {
  const _ToneRadarChart({
    required this.formal,
    required this.serious,
    required this.bold,
  });

  final int formal;
  final int serious;
  final int bold;

  @override
  Widget build(BuildContext context) {
    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        tickCount: 5,
        ticksTextStyle: const TextStyle(fontSize: 0),
        tickBorderData: BorderSide(
          color: AppColors.mutedDark.withValues(alpha: 0.3),
          width: 1,
        ),
        gridBorderData: BorderSide(
          color: AppColors.mutedDark.withValues(alpha: 0.3),
          width: 1,
        ),
        radarBorderData:
            const BorderSide(color: Colors.transparent, width: 0),
        titleTextStyle: const TextStyle(
          color: AppColors.mutedDark,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        getTitle: (index, _) => RadarChartTitle(
          text: switch (index) {
            0 => 'Formal',
            1 => 'Serious',
            2 => 'Bold',
            _ => '',
          },
        ),
        dataSets: [
          RadarDataSet(
            dataEntries: [
              RadarEntry(value: formal.toDouble()),
              RadarEntry(value: serious.toDouble()),
              RadarEntry(value: bold.toDouble()),
            ],
            fillColor: AppColors.blockLime.withValues(alpha: 0.2),
            borderColor: AppColors.blockLime,
            borderWidth: 2,
            entryRadius: 3,
          ),
        ],
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
