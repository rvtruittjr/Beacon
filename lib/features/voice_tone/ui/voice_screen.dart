import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/design_tokens.dart';
import '../../../core/config/app_fonts.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../models/voice_model.dart';
import '../providers/voice_provider.dart';
import 'widgets/archetype_selector.dart';
import 'widgets/voice_examples_section.dart';
import 'widgets/word_list_section.dart';

/// Provider that creates the editor notifier once voice data loads.
final voiceEditorProvider =
    StateNotifierProvider.autoDispose<VoiceEditorNotifier, VoiceModel>(
        (ref) {
  final brandId = ref.watch(currentBrandProvider) ?? '';
  final repo = ref.watch(voiceRepositoryProvider);
  // We initialise with defaults; the screen replaces this once data loads.
  return VoiceEditorNotifier(
    repo,
    brandId,
    VoiceModel(brandId: brandId),
  );
});

class VoiceScreen extends ConsumerStatefulWidget {
  const VoiceScreen({super.key});

  @override
  ConsumerState<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends ConsumerState<VoiceScreen> {
  bool _initialised = false;

  @override
  Widget build(BuildContext context) {
    final voiceAsync = ref.watch(voiceProvider);

    return voiceAsync.when(
      loading: () => const LoadingIndicator(caption: 'Loading voice profile…'),
      error: (_, __) => const Center(child: Text('Failed to load voice data')),
      data: (voice) {
        // Seed the editor notifier once
        if (!_initialised && voice != null) {
          Future.microtask(() {
            final brandId = ref.read(currentBrandProvider) ?? '';
            ref.read(voiceEditorProvider.notifier)
              ..setArchetype(voice.archetype ?? '')
              ..setToneFormal(voice.toneFormal)
              ..setToneSerious(voice.toneSerious)
              ..setToneBold(voice.toneBold)
              ..setMissionStatement(voice.missionStatement ?? '')
              ..setTagline(voice.tagline ?? '');
            // Words need direct state replacement
          });
          _initialised = true;
        }

        return _VoiceScreenBody(initial: voice);
      },
    );
  }
}

class _VoiceScreenBody extends ConsumerStatefulWidget {
  const _VoiceScreenBody({this.initial});
  final VoiceModel? initial;

  @override
  ConsumerState<_VoiceScreenBody> createState() => _VoiceScreenBodyState();
}

class _VoiceScreenBodyState extends ConsumerState<_VoiceScreenBody>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _missionController;
  late final TextEditingController _taglineController;
  bool _missionFocused = false;
  bool _taglineFocused = false;
  late AnimationController _chartAnimController;
  late Animation<double> _chartAnim;

  @override
  void initState() {
    super.initState();
    _missionController = TextEditingController(
        text: widget.initial?.missionStatement ?? '');
    _taglineController =
        TextEditingController(text: widget.initial?.tagline ?? '');

    _chartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _chartAnim = CurvedAnimation(
      parent: _chartAnimController,
      curve: Curves.easeOut,
    );
    _chartAnimController.forward();
  }

  @override
  void dispose() {
    _missionController.dispose();
    _taglineController.dispose();
    _chartAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final voice = ref.watch(voiceEditorProvider);
    final isDesktop = MediaQuery.sizeOf(context).width > 768;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.x2l,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Voice & Tone',
                style: AppFonts.clashDisplay(fontSize: 32, color: textColor),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Two-column / single-column layout
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildLeftColumn(
                              voice, textColor, mutedColor),
                        ),
                        const SizedBox(width: AppSpacing.xl),
                        Expanded(
                          flex: 2,
                          child: _buildRadarChart(voice),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLeftColumn(voice, textColor, mutedColor),
                        const SizedBox(height: AppSpacing.xl),
                        _buildRadarChart(voice),
                      ],
                    ),
              const SizedBox(height: AppSpacing.x2l),
              // Voice examples
              const VoiceExamplesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftColumn(
      VoiceModel voice, Color textColor, Color mutedColor) {
    final notifier = ref.read(voiceEditorProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Archetype ──
        Text(
          voice.archetype?.isNotEmpty == true
              ? voice.archetype!
              : 'Choose your archetype',
          style: AppFonts.clashDisplay(
            fontSize: 32,
            color: voice.archetype?.isNotEmpty == true
                ? textColor
                : mutedColor,
          ),
        ),
        if (voice.archetype?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _archetypeDescription(voice.archetype!),
              style: AppFonts.inter(fontSize: 14, color: mutedColor),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: () => ArchetypeSelector.show(context, (archetype) {
            notifier.setArchetype(archetype);
          }),
          child: Text(
            'Change',
            style: AppFonts.inter(fontSize: 14, color: mutedColor),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Tone sliders ──
        _ToneSlider(
          lowLabel: 'Casual',
          highLabel: 'Professional',
          value: voice.toneFormal,
          descriptor: voice.toneDescriptor('formal', voice.toneFormal),
          onChanged: (v) => notifier.setToneFormal(v),
        ),
        const SizedBox(height: AppSpacing.lg),
        _ToneSlider(
          lowLabel: 'Playful',
          highLabel: 'Serious',
          value: voice.toneSerious,
          descriptor: voice.toneDescriptor('serious', voice.toneSerious),
          onChanged: (v) => notifier.setToneSerious(v),
        ),
        const SizedBox(height: AppSpacing.lg),
        _ToneSlider(
          lowLabel: 'Reserved',
          highLabel: 'Bold',
          value: voice.toneBold,
          descriptor: voice.toneDescriptor('bold', voice.toneBold),
          onChanged: (v) => notifier.setToneBold(v),
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Mission statement ──
        Text(
          'Mission Statement',
          style: AppFonts.inter(fontSize: 12, color: mutedColor)
              .copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Focus(
          onFocusChange: (f) => setState(() => _missionFocused = f),
          child: _missionFocused
              ? TextField(
                  controller: _missionController,
                  maxLines: 3,
                  onChanged: (v) => notifier.setMissionStatement(v),
                  decoration: const InputDecoration(
                    hintText: 'What drives your brand?',
                  ),
                )
              : GestureDetector(
                  onTap: () => setState(() => _missionFocused = true),
                  child: Container(
                    width: double.infinity,
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
                      _missionController.text.isNotEmpty
                          ? _missionController.text
                          : 'What drives your brand?',
                      style: AppFonts.inter(
                        fontSize: 15,
                        color: _missionController.text.isNotEmpty
                            ? (Theme.of(context).brightness == Brightness.dark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight)
                            : mutedColor,
                      ).copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Tagline ──
        Text(
          'Tagline',
          style: AppFonts.inter(fontSize: 12, color: mutedColor)
              .copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Focus(
          onFocusChange: (f) => setState(() => _taglineFocused = f),
          child: _taglineFocused
              ? TextField(
                  controller: _taglineController,
                  onChanged: (v) => notifier.setTagline(v),
                  decoration: const InputDecoration(
                    hintText: 'Your brand in a few words',
                  ),
                )
              : GestureDetector(
                  onTap: () => setState(() => _taglineFocused = true),
                  child: Text(
                    _taglineController.text.isNotEmpty
                        ? _taglineController.text
                        : 'Your brand in a few words',
                    style: AppFonts.caveat(
                      fontSize: 32,
                      color: _taglineController.text.isNotEmpty
                          ? (Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight)
                          : mutedColor,
                    ).copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Word lists ──
        WordListSection(
          wordsWeUse: voice.wordsWeUse,
          wordsWeAvoid: voice.wordsWeAvoid,
          onAddWeUse: (w) => notifier.addWordWeUse(w),
          onRemoveWeUse: (w) => notifier.removeWordWeUse(w),
          onAddWeAvoid: (w) => notifier.addWordWeAvoid(w),
          onRemoveWeAvoid: (w) => notifier.removeWordWeAvoid(w),
        ),
      ],
    );
  }

  Widget _buildRadarChart(VoiceModel voice) {
    return AnimatedBuilder(
      animation: _chartAnim,
      builder: (context, _) {
        final t = _chartAnim.value;
        return SizedBox(
          height: 280,
          child: RadarChart(
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
              radarBorderData: const BorderSide(
                  color: Colors.transparent, width: 0),
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
                    RadarEntry(value: voice.toneFormal * t),
                    RadarEntry(value: voice.toneSerious * t),
                    RadarEntry(value: voice.toneBold * t),
                  ],
                  fillColor: AppColors.blockLime.withValues(alpha: 0.3),
                  borderColor: AppColors.blockLime,
                  borderWidth: 2,
                  entryRadius: 3,
                ),
              ],
              borderData: FlBorderData(show: false),
            ),
          ),
        );
      },
    );
  }

  String _archetypeDescription(String archetype) {
    return switch (archetype) {
      'The Creator' => 'Innovative, expressive, and imaginative.',
      'The Rebel' => 'Disruptive, bold, and unapologetic.',
      'The Hero' => 'Courageous, determined, and inspiring.',
      'The Sage' => 'Wise, thoughtful, and knowledge-driven.',
      'The Explorer' => 'Adventurous, curious, and freedom-seeking.',
      'The Entertainer' => 'Fun, energetic, and light-hearted.',
      'The Advocate' => 'Passionate, empathetic, and mission-driven.',
      'The Specialist' => 'Expert, precise, and authoritative.',
      _ => '',
    };
  }
}

// ─── Tone slider ────────────────────────────────────────────────

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
                    fontSize: 14,
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
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
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
