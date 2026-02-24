import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../shared/widgets/app_button.dart';
import 'onboarding_state.dart';

class StepBrandFonts extends ConsumerStatefulWidget {
  const StepBrandFonts({super.key});

  @override
  ConsumerState<StepBrandFonts> createState() => _StepBrandFontsState();
}

class _StepBrandFontsState extends ConsumerState<StepBrandFonts> {
  final _familyController = TextEditingController();
  String? _selectedLabel;

  static const _labels = ['Heading', 'Body', 'Display', 'Caption', 'Accent'];

  static const _suggestedFonts = [
    'Inter',
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Poppins',
    'Raleway',
    'Playfair Display',
    'Merriweather',
    'Source Sans Pro',
    'Nunito',
    'Work Sans',
    'DM Sans',
    'Space Grotesk',
    'Outfit',
    'Sora',
    'Manrope',
    'Archivo',
  ];

  @override
  void dispose() {
    _familyController.dispose();
    super.dispose();
  }

  void _addFont() {
    final family = _familyController.text.trim();
    if (family.isEmpty) return;

    ref.read(onboardingProvider.notifier).addFont(
          OnboardingFont(
            family: family,
            label: _selectedLabel,
            weight: '600',
          ),
        );

    _familyController.clear();
    setState(() => _selectedLabel = null);
  }

  @override
  Widget build(BuildContext context) {
    final fonts = ref.watch(onboardingProvider).selectedFonts;

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
                  'Pick your fonts.',
                  style: AppFonts.clashDisplay(
                    fontSize: 40,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Choose a heading and body font to define your brand\'s type style.',
                  style: AppFonts.inter(
                    fontSize: 14,
                    color: AppColors.mutedDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Add font row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Autocomplete<String>(
                        initialValue: _familyController.value,
                        optionsBuilder: (textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return _suggestedFonts;
                          }
                          final query = textEditingValue.text.toLowerCase();
                          return _suggestedFonts
                              .where((f) => f.toLowerCase().contains(query));
                        },
                        onSelected: (value) {
                          _familyController.text = value;
                          setState(() {});
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.all(AppRadius.md),
                              color: AppColors.surfaceDark,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 200,
                                  maxWidth: 280,
                                ),
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.xs),
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final font = options.elementAt(index);
                                    TextStyle fontStyle;
                                    try {
                                      fontStyle = GoogleFonts.getFont(
                                        font,
                                        fontSize: 14,
                                        color: AppColors.textPrimaryDark,
                                      );
                                    } catch (_) {
                                      fontStyle = TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textPrimaryDark,
                                      );
                                    }
                                    return ListTile(
                                      dense: true,
                                      title: Text(font, style: fontStyle),
                                      onTap: () => onSelected(font),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                          controller.addListener(() {
                            if (_familyController.text != controller.text) {
                              _familyController.text = controller.text;
                              setState(() {});
                            }
                          });
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            style: const TextStyle(
                                color: AppColors.textPrimaryDark),
                            decoration: InputDecoration(
                              hintText: 'Font family',
                              hintStyle:
                                  TextStyle(color: AppColors.mutedDark),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 14,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _selectedLabel,
                        dropdownColor: AppColors.surfaceDark,
                        style:
                            const TextStyle(color: AppColors.textPrimaryDark),
                        decoration: InputDecoration(
                          hintText: 'Label',
                          hintStyle: TextStyle(color: AppColors.mutedDark),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 14,
                          ),
                        ),
                        items: _labels
                            .map((l) =>
                                DropdownMenuItem(value: l, child: Text(l)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedLabel = v),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton(
                      onPressed:
                          _familyController.text.trim().isNotEmpty ? _addFont : null,
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.blockLime,
                      disabledColor: AppColors.mutedDark,
                      iconSize: 28,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Preview of selected fonts
                if (fonts.isNotEmpty) ...[
                  ...fonts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final font = entry.value;
                    TextStyle fontStyle;
                    try {
                      fontStyle = GoogleFonts.getFont(
                        font.family,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryDark,
                      );
                    } catch (_) {
                      fontStyle = TextStyle(
                        fontFamily: font.family,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryDark,
                      );
                    }
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(font.family, style: fontStyle),
                                if (font.label != null)
                                  Text(
                                    font.label!,
                                    style: AppFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.blockLime,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => ref
                                .read(onboardingProvider.notifier)
                                .removeFont(index),
                            icon: const Icon(Icons.close, size: 18),
                            color: AppColors.mutedDark,
                          ),
                        ],
                      ),
                    );
                  }),
                ] else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Text(
                      'Type a font name or pick from the suggestions above.',
                      style: AppFonts.inter(
                        fontSize: 13,
                        color: AppColors.mutedDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: AppSpacing.lg),

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
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: TextButton(
                    onPressed: () =>
                        ref.read(onboardingProvider.notifier).nextStep(),
                    child: Text(
                      'Skip for now',
                      style: AppFonts.inter(
                        fontSize: 14,
                        color: AppColors.mutedDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
