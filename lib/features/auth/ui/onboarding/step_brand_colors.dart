import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../shared/widgets/app_button.dart';
import 'onboarding_state.dart';

class StepBrandColors extends ConsumerWidget {
  const StepBrandColors({super.key});

  static const _labels = ['Primary', 'Accent', 'Background'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(onboardingProvider).selectedColors;

    return Container(
      color: AppColors.backgroundDark,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add your brand colors.',
                style: AppFonts.clashDisplay(
                  fontSize: 40,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _labels.map((label) {
                  final color = colors[label];
                  return _ColorSwatch(
                    label: label,
                    color: color,
                    onTap: () => _showColorPicker(context, ref, label, color),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.x2l),
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
    );
  }

  void _showColorPicker(
    BuildContext context,
    WidgetRef ref,
    String label,
    Color? current,
  ) {
    final hexController = TextEditingController(
      text: current != null
          ? '#${current.value.toRadixString(16).substring(2).toUpperCase()}'
          : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: AppRadius.lg),
      ),
      builder: (ctx) {
        Color preview = current ?? AppColors.blockViolet;

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.lg,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(label, style: Theme.of(ctx).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  // Simple color grid
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _presetColors.map((c) {
                      final isSelected = c.value == preview.value;
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() => preview = c);
                          hexController.text =
                              '#${c.value.toRadixString(16).substring(2).toUpperCase()}';
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: AppColors.textPrimaryDark,
                                    width: 3)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: hexController,
                    decoration: const InputDecoration(
                      labelText: 'Hex color',
                      hintText: '#FF5733',
                    ),
                    onChanged: (value) {
                      final clean = value.replaceFirst('#', '');
                      if (clean.length == 6 &&
                          RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(clean)) {
                        setSheetState(() {
                          preview =
                              Color(int.parse('FF$clean', radix: 16));
                        });
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Preview
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: preview,
                      borderRadius: BorderRadius.all(AppRadius.md),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'Done',
                    onPressed: () {
                      ref
                          .read(onboardingProvider.notifier)
                          .setColor(label, preview);
                      Navigator.of(ctx).pop();
                    },
                    isFullWidth: true,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static const _presetColors = [
    Color(0xFF6C63FF),
    Color(0xFFFF6B6B),
    Color(0xFFC8F135),
    Color(0xFFFFD166),
    Color(0xFF22C55E),
    Color(0xFF1DA1F2),
    Color(0xFFE1306C),
    Color(0xFF1A1A1A),
    Color(0xFFFFFFFF),
    Color(0xFF0D0D2B),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
  ];
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: color == null
                  ? Border.all(
                      color: AppColors.mutedDark,
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignInside,
                    )
                  : null,
            ),
            child: color == null
                ? const Icon(Icons.add, color: AppColors.mutedDark, size: 24)
                : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.mutedDark,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
