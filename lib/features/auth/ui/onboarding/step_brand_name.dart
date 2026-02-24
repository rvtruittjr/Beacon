import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../shared/widgets/app_button.dart';
import 'onboarding_state.dart';

class StepBrandName extends ConsumerStatefulWidget {
  const StepBrandName({super.key});

  @override
  ConsumerState<StepBrandName> createState() => _StepBrandNameState();
}

class _StepBrandNameState extends ConsumerState<StepBrandName> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(onboardingProvider).brandName,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                "What's your brand called?",
                style: AppFonts.clashDisplay(
                  fontSize: 40,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'You can add more brands later.',
                style: AppFonts.inter(
                  fontSize: 14,
                  color: AppColors.mutedDark,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (value) {
                  ref.read(onboardingProvider.notifier).setBrandName(value);
                  setState(() {});
                },
                style: AppFonts.inter(
                  fontSize: 18,
                  color: AppColors.textPrimaryDark,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. My Creator Brand',
                  hintStyle: AppFonts.inter(
                    fontSize: 18,
                    color: AppColors.mutedDark,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 18,
                  ),
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
                      onPressed: _controller.text.trim().length >= 2
                          ? () => ref
                              .read(onboardingProvider.notifier)
                              .nextStep()
                          : null,
                      isFullWidth: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
