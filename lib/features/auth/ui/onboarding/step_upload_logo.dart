import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../shared/widgets/app_button.dart';
import 'onboarding_state.dart';

class StepUploadLogo extends ConsumerWidget {
  const StepUploadLogo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoFile = ref.watch(onboardingProvider).logoFile;

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
                'Drop in your logo.',
                style: AppFonts.clashDisplay(
                  fontSize: 40,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Upload zone
              GestureDetector(
                onTap: () => _pickFile(ref),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(AppRadius.lg),
                    border: Border.all(
                      color: AppColors.mutedDark,
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
                  child: logoFile != null
                      ? _buildPreview(logoFile)
                      : _buildPlaceholder(),
                ),
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

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.cloud_upload_outlined,
            size: 48, color: AppColors.mutedDark),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Click to upload SVG, PNG, or JPG',
          style: AppFonts.inter(fontSize: 14, color: AppColors.mutedDark),
        ),
      ],
    );
  }

  Widget _buildPreview(PlatformFile file) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (file.bytes != null)
          Image.memory(
            file.bytes!,
            width: 80,
            height: 80,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.image,
              size: 48,
              color: AppColors.blockLime,
            ),
          )
        else
          const Icon(Icons.check_circle, size: 48, color: AppColors.blockLime),
        const SizedBox(height: AppSpacing.sm),
        Text(
          file.name,
          style: const TextStyle(
            color: AppColors.mutedDark,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Future<void> _pickFile(WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['svg', 'png', 'jpg', 'jpeg'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      ref.read(onboardingProvider.notifier).setLogoFile(result.files.first);
    }
  }
}
