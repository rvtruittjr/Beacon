import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/design_tokens.dart';
import 'onboarding_state.dart';
import 'step_welcome.dart';
import 'step_brand_colors.dart';
import 'step_brand_fonts.dart';
import 'step_upload_logo.dart';
import 'step_your_voice.dart';
import 'step_done.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(onboardingProvider).currentStep;

    ref.listen<OnboardingData>(onboardingProvider, (prev, next) {
      if (prev?.currentStep != next.currentStep) {
        _pageController.animateToPage(
          next.currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Progress dots
            const SizedBox(height: 20),
            _ProgressDots(currentStep: currentStep, totalSteps: 6),
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  StepWelcome(),
                  StepBrandColors(),
                  StepBrandFonts(),
                  StepUploadLogo(),
                  StepYourVoice(),
                  StepDone(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.currentStep, required this.totalSteps});

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: isActive ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isActive ? AppColors.blockLime : AppColors.mutedDark,
            borderRadius: BorderRadius.all(AppRadius.full),
          ),
        );
      }),
    );
  }
}
