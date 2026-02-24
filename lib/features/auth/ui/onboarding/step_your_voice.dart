import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../shared/widgets/app_button.dart';
import 'onboarding_state.dart';

class StepYourVoice extends ConsumerWidget {
  const StepYourVoice({super.key});

  String _describeValue(int value, String lowLabel, String highLabel) {
    return switch (value) {
      1 || 2 => 'Very $lowLabel',
      3 || 4 => 'Mostly $lowLabel',
      5 || 6 => 'Balanced',
      7 || 8 => 'Mostly $highLabel',
      _ => 'Very $highLabel',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(onboardingProvider);

    return Container(
      color: AppColors.backgroundDark,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How do you talk to your audience?',
                  style: AppFonts.clashDisplay(
                    fontSize: 40,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Casual ↔ Professional
                _ToneSlider(
                  lowLabel: 'Casual',
                  highLabel: 'Professional',
                  value: data.toneFormal,
                  descriptor:
                      _describeValue(data.toneFormal, 'casual', 'professional'),
                  onChanged: (v) =>
                      ref.read(onboardingProvider.notifier).setToneFormal(v),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Playful ↔ Serious
                _ToneSlider(
                  lowLabel: 'Playful',
                  highLabel: 'Serious',
                  value: data.toneSerious,
                  descriptor:
                      _describeValue(data.toneSerious, 'playful', 'serious'),
                  onChanged: (v) =>
                      ref.read(onboardingProvider.notifier).setToneSerious(v),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Reserved ↔ Bold
                _ToneSlider(
                  lowLabel: 'Reserved',
                  highLabel: 'Bold',
                  value: data.toneBold,
                  descriptor:
                      _describeValue(data.toneBold, 'reserved', 'bold'),
                  onChanged: (v) =>
                      ref.read(onboardingProvider.notifier).setToneBold(v),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Radar chart
                SizedBox(
                  height: 200,
                  child: _ToneRadarChart(
                    formal: data.toneFormal,
                    serious: data.toneSerious,
                    bold: data.toneBold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    AppButton(
                      label: 'Back',
                      onPressed: () =>
                          ref.read(onboardingProvider.notifier).previousStep(),
                      variant: AppButtonVariant.ghost,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppButton(
                        label: 'Continue',
                        onPressed: () =>
                            ref.read(onboardingProvider.notifier).nextStep(),
                        isFullWidth: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToneSlider extends StatelessWidget {
  const _ToneSlider({
    required this.lowLabel,
    required this.highLabel,
    required this.value,
    required this.descriptor,
    required this.onChanged,
  });

  final String lowLabel;
  final String highLabel;
  final int value;
  final String descriptor;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(lowLabel,
                style: const TextStyle(
                    color: AppColors.mutedDark, fontSize: 12)),
            Text(descriptor,
                style: const TextStyle(
                    color: AppColors.blockLime,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            Text(highLabel,
                style: const TextStyle(
                    color: AppColors.mutedDark, fontSize: 12)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.blockLime,
            inactiveTrackColor: AppColors.surfaceMidDark,
            thumbColor: AppColors.blockLime,
            overlayColor: AppColors.blockLime.withValues(alpha: 0.15),
            trackHeight: 4,
          ),
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (v) => onChanged(v.round()),
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
