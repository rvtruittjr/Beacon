import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../shared/widgets/app_button.dart';
import 'onboarding_state.dart';

class StepWelcome extends ConsumerWidget {
  const StepWelcome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.backgroundDark,
      child: Stack(
        children: [
          // Floating decorative elements
          Positioned(
            top: 60,
            right: 40,
            child: Transform.rotate(
              angle: 12 * 3.14159 / 180,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.blockViolet,
                  borderRadius: BorderRadius.all(AppRadius.md),
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(
                    end: 4,
                    duration: AppDurations.floater,
                    curve: Curves.easeInOut),
          ),
          Positioned(
            top: 200,
            left: 30,
            child: Transform.rotate(
              angle: -8 * 3.14159 / 180,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.all(AppRadius.full),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Icon(
                  Icons.hexagon_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(
                    end: 4,
                    duration: AppDurations.floater,
                    curve: Curves.easeInOut),
          ),
          Positioned(
            bottom: 120,
            right: 50,
            child: Transform.rotate(
              angle: 6 * 3.14159 / 180,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.all(AppRadius.md),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Text(
                  'Aa',
                  style: AppFonts.clashDisplay(
                    fontSize: 28,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(
                    end: 4,
                    duration: AppDurations.floater,
                    curve: Curves.easeInOut),
          ),
          // Hero content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Beacøn',
                    style: AppFonts.clashDisplay(
                      fontSize: 64,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'always lit.',
                    style: AppFonts.caveat(
                      fontSize: 36,
                      color: AppColors.mutedDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'The brand identity system built for creators.\nEverything in one place — finally.',
                    style: AppFonts.inter(
                      fontSize: 16,
                      color: AppColors.mutedDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.x2l),
                  AppButton(
                    label: 'Get started →',
                    onPressed: () =>
                        ref.read(onboardingProvider.notifier).nextStep(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
