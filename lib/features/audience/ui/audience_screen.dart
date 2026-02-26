import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/config/design_tokens.dart';
import '../../../core/config/app_fonts.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../models/audience_model.dart';
import '../providers/audience_provider.dart';
import 'widgets/social_accounts_section.dart';
import 'widgets/tag_input_section.dart';

/// Provider that creates the editor notifier once audience data loads.
final audienceEditorProvider =
    StateNotifierProvider.autoDispose<AudienceEditorNotifier, AudienceModel>(
        (ref) {
  final brandId = ref.watch(currentBrandProvider) ?? '';
  final repo = ref.watch(audienceRepositoryProvider);
  return AudienceEditorNotifier(repo, brandId, AudienceModel(brandId: brandId));
});

class AudienceScreen extends ConsumerStatefulWidget {
  const AudienceScreen({super.key});

  @override
  ConsumerState<AudienceScreen> createState() => _AudienceScreenState();
}

class _AudienceScreenState extends ConsumerState<AudienceScreen> {
  bool _initialised = false;

  @override
  Widget build(BuildContext context) {
    final audienceAsync = ref.watch(audienceProvider);

    return audienceAsync.when(
      loading: () =>
          const LoadingIndicator(caption: 'Loading audience profile…'),
      error: (_, __) =>
          const Center(child: Text('Failed to load audience data')),
      data: (audience) {
        if (!_initialised && audience != null) {
          Future.microtask(() {
            ref.read(audienceEditorProvider.notifier).seed(audience);
          });
          _initialised = true;
        }

        return _AudienceScreenBody(initial: audience);
      },
    );
  }
}

class _AudienceScreenBody extends ConsumerStatefulWidget {
  const _AudienceScreenBody({this.initial});
  final AudienceModel? initial;

  @override
  ConsumerState<_AudienceScreenBody> createState() =>
      _AudienceScreenBodyState();
}

class _AudienceScreenBodyState extends ConsumerState<_AudienceScreenBody> {
  late final TextEditingController _nameController;
  late final TextEditingController _summaryController;
  late final TextEditingController _ageMinController;
  late final TextEditingController _ageMaxController;
  bool _nameFocused = false;
  bool _summaryFocused = false;
  bool _dismissedEmpty = false;

  static const _genderOptions = [
    'Mostly Female',
    'Mixed',
    'Mostly Male',
    'Non-binary skew',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initial?.personaName ?? '');
    _summaryController =
        TextEditingController(text: widget.initial?.personaSummary ?? '');
    _ageMinController =
        TextEditingController(text: widget.initial?.ageRangeMin?.toString() ?? '');
    _ageMaxController =
        TextEditingController(text: widget.initial?.ageRangeMax?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _summaryController.dispose();
    _ageMinController.dispose();
    _ageMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final audience = ref.watch(audienceEditorProvider);
    final notifier = ref.read(audienceEditorProvider.notifier);

    // Show empty state if nothing saved yet and editor is still empty
    if (!_dismissedEmpty && widget.initial == null && audience.isEmpty) {
      return _EmptyState(onGetStarted: () {
        setState(() {
          _dismissedEmpty = true;
          _nameFocused = true;
        });
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.x2l,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Text(
                'Your Audience',
                style: AppFonts.clashDisplay(
                  fontSize: 32,
                  color: textColor,
                ),
              ),
              const SizedBox(height: AppSpacing.x2l),

              // ── PERSONA SECTION ──
              _SectionHeading(label: 'PERSONA', color: mutedColor),
              const SizedBox(height: AppSpacing.md),

              // Persona name (focus-swap)
              Focus(
                onFocusChange: (f) => setState(() => _nameFocused = f),
                child: _nameFocused
                    ? TextField(
                        controller: _nameController,
                        autofocus: true,
                        style: AppFonts.clashDisplay(
                            fontSize: 28, color: textColor),
                        onChanged: (v) => notifier.setPersonaName(v),
                        decoration: const InputDecoration(
                          hintText: 'Persona name',
                          border: InputBorder.none,
                        ),
                      )
                    : GestureDetector(
                        onTap: () => setState(() => _nameFocused = true),
                        child: Text(
                          _nameController.text.isNotEmpty
                              ? _nameController.text
                              : 'Persona name',
                          style: AppFonts.clashDisplay(
                            fontSize: 28,
                            color: _nameController.text.isNotEmpty
                                ? textColor
                                : mutedColor,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Persona summary (focus-swap)
              Focus(
                onFocusChange: (f) => setState(() => _summaryFocused = f),
                child: _summaryFocused
                    ? TextField(
                        controller: _summaryController,
                        autofocus: true,
                        maxLines: 3,
                        onChanged: (v) => notifier.setPersonaSummary(v),
                        decoration: const InputDecoration(
                          hintText:
                              'Describe your ideal audience member in a few sentences…',
                        ),
                      )
                    : GestureDetector(
                        onTap: () => setState(() => _summaryFocused = true),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          child: Text(
                            _summaryController.text.isNotEmpty
                                ? _summaryController.text
                                : 'Describe your ideal audience member in a few sentences…',
                            style: AppFonts.inter(
                              fontSize: 15,
                              color: _summaryController.text.isNotEmpty
                                  ? textColor
                                  : mutedColor,
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: AppSpacing.x2l),
              Divider(color: borderColor, height: 1),
              const SizedBox(height: AppSpacing.x2l),

              // ── DEMOGRAPHICS SECTION ──
              _SectionHeading(label: 'DEMOGRAPHICS', color: mutedColor),
              const SizedBox(height: AppSpacing.md),

              // Age range + Gender skew in 2-column grid
              LayoutBuilder(builder: (context, constraints) {
                final isWide = constraints.maxWidth > 500;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildAgeRange(mutedColor)),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: _buildGenderSkew(audience, notifier, mutedColor)),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAgeRange(mutedColor),
                    const SizedBox(height: AppSpacing.lg),
                    _buildGenderSkew(audience, notifier, mutedColor),
                  ],
                );
              }),
              const SizedBox(height: AppSpacing.lg),

              // Locations
              TagInputSection(
                label: 'LOCATIONS',
                hintText: 'Add city or country + Enter',
                chipColor: AppColors.blockLime,
                chipTextColor: AppColors.textOnLime,
                values: audience.locations,
                onAdd: notifier.addLocation,
                onRemove: notifier.removeLocation,
              ),
              const SizedBox(height: AppSpacing.x2l),
              Divider(color: borderColor, height: 1),
              const SizedBox(height: AppSpacing.x2l),

              // ── PSYCHOGRAPHICS SECTION ──
              _SectionHeading(label: 'PSYCHOGRAPHICS', color: mutedColor),
              const SizedBox(height: AppSpacing.md),

              TagInputSection(
                label: 'INTERESTS',
                hintText: 'Add an interest + Enter',
                chipColor: AppColors.blockLime,
                chipTextColor: AppColors.textOnLime,
                values: audience.interests,
                onAdd: notifier.addInterest,
                onRemove: notifier.removeInterest,
              ),
              const SizedBox(height: AppSpacing.lg),

              TagInputSection(
                label: 'PAIN POINTS',
                hintText: 'Add a pain point + Enter',
                chipColor: AppColors.blockCoral,
                chipTextColor: AppColors.textOnCoral,
                values: audience.painPoints,
                onAdd: notifier.addPainPoint,
                onRemove: notifier.removePainPoint,
              ),
              const SizedBox(height: AppSpacing.lg),

              TagInputSection(
                label: 'GOALS',
                hintText: 'Add a goal + Enter',
                chipColor: AppColors.blockYellow,
                chipTextColor: AppColors.textOnYellow,
                values: audience.goals,
                onAdd: notifier.addGoal,
                onRemove: notifier.removeGoal,
              ),
              const SizedBox(height: AppSpacing.x2l),
              Divider(color: borderColor, height: 1),
              const SizedBox(height: AppSpacing.x2l),

              // ── SOCIAL ACCOUNTS SECTION ──
              const SocialAccountsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgeRange(Color mutedColor) {
    final notifier = ref.read(audienceEditorProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AGE RANGE',
          style: AppFonts.inter(fontSize: 11, color: mutedColor)
              .copyWith(fontWeight: FontWeight.w600, letterSpacing: 1),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ageMinController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'From',
                  isDense: true,
                ),
                onChanged: (v) {
                  final val = int.tryParse(v);
                  notifier.setAgeRangeMin(val);
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextField(
                controller: _ageMaxController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'To',
                  isDense: true,
                ),
                onChanged: (v) {
                  final val = int.tryParse(v);
                  notifier.setAgeRangeMax(val);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderSkew(
    AudienceModel audience,
    AudienceEditorNotifier notifier,
    Color mutedColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GENDER SKEW',
          style: AppFonts.inter(fontSize: 11, color: mutedColor)
              .copyWith(fontWeight: FontWeight.w600, letterSpacing: 1),
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          value: audience.genderSkew,
          isExpanded: true,
          decoration: const InputDecoration(isDense: true),
          items: _genderOptions
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (v) => notifier.setGenderSkew(v),
        ),
      ],
    );
  }
}

// ─── Section heading ────────────────────────────────────────────

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppFonts.inter(fontSize: 12, color: color)
          .copyWith(fontWeight: FontWeight.w600, letterSpacing: 1.2),
    );
  }
}

// ─── Empty state ────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onGetStarted});
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.x2l),
          decoration: BoxDecoration(
            color: AppColors.sidebarBg,
            borderRadius: BorderRadius.all(AppRadius.xl),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.users,
                size: 48,
                color: AppColors.sidebarMuted,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Who are you talking to?',
                style: AppFonts.clashDisplay(
                  fontSize: 28,
                  color: AppColors.sidebarText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Define your audience',
                variant: AppButtonVariant.primary,
                onPressed: onGetStarted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
