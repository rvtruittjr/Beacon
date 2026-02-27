import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../brands/providers/brand_provider.dart';
import 'onboarding_state.dart';

class StepDone extends ConsumerStatefulWidget {
  const StepDone({super.key});

  @override
  ConsumerState<StepDone> createState() => _StepDoneState();
}

class _StepDoneState extends ConsumerState<StepDone> {
  bool _isSaving = false;

  Future<void> _finish() async {
    setState(() => _isSaving = true);

    try {
      final data = ref.read(onboardingProvider);
      final brandId = ref.read(currentBrandProvider);
      final client = SupabaseService.client;

      if (brandId == null) return;

      // Save brand colors
      for (final entry in data.selectedColors.entries) {
        final hex =
            '#${entry.value.value.toRadixString(16).substring(2).toUpperCase()}';
        await client.from('brand_colors').insert({
          'brand_id': brandId,
          'label': entry.key,
          'hex': hex,
        });
      }

      // Save brand fonts
      final user = client.auth.currentUser;
      for (var i = 0; i < data.selectedFonts.length; i++) {
        final font = data.selectedFonts[i];
        String? fontUrl;
        if (font.source == 'upload' && font.file != null && user != null) {
          fontUrl = await StorageService.uploadFont(
            user.id,
            brandId,
            font.file!,
          );
        }
        await client.from('brand_fonts').insert({
          'brand_id': brandId,
          'family': font.family,
          'label': font.label,
          'weight': font.weight,
          'source': font.source,
          if (fontUrl != null) 'url': fontUrl,
          'sort_order': i,
        });
      }

      // Save brand voice
      await client.from('brand_voice').upsert({
        'brand_id': brandId,
        'tone_formal': data.toneFormal,
        'tone_serious': data.toneSerious,
        'tone_bold': data.toneBold,
      });

      // Upload logo if selected
      if (data.logoFile != null && data.logoFile!.bytes != null) {
        if (user != null) {
          final path =
              '${user.id}/$brandId/assets/logo/${data.logoFile!.name}';
          await client.storage.from('brand-assets').uploadBinary(
                path,
                data.logoFile!.bytes!,
                fileOptions: FileOptions(upsert: true),
              );

          final url =
              client.storage.from('brand-assets').getPublicUrl(path);

          await client.from('assets').insert({
            'brand_id': brandId,
            'user_id': user.id,
            'name': data.logoFile!.name,
            'file_url': url,
            'file_type': 'logo',
            'mime_type': 'image/${data.logoFile!.extension ?? 'png'}',
          });
        }
      }

      // Mark onboarding complete
      await ref
          .read(brandRepositoryProvider)
          .updateBrand(brandId, onboardingComplete: true);

      ref.invalidate(userBrandsProvider);
      ref.invalidate(activeBrandProvider);

      if (mounted) context.go('/app/snapshot');
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(onboardingProvider);

    return Container(
      color: AppColors.blockYellow,
      child: Stack(
        children: [
          // Confetti
          ..._buildConfetti(),
          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Your brand has a home.',
                    style: AppFonts.clashDisplay(
                      fontSize: 56,
                      color: AppColors.textOnYellow,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Mini preview card
                  _BrandPreviewCard(data: data)
                      .animate()
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0),
                        duration: 500.ms,
                        curve: Curves.elasticOut,
                      ),
                  const SizedBox(height: AppSpacing.x2l),
                  AppButton(
                    label: 'Enter Beacøn →',
                    onPressed: _isSaving ? null : _finish,
                    isLoading: _isSaving,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildConfetti() {
    final rng = Random(42);
    final colors = [
      AppColors.blockViolet,
      AppColors.blockCoral,
      Theme.of(context).colorScheme.primary,
      AppColors.backgroundDark,
    ];

    return List.generate(50, (i) {
      final color = colors[i % colors.length];
      final left = rng.nextDouble() * 400;
      final top = rng.nextDouble() * 100;
      final size = 6.0 + rng.nextDouble() * 8;
      final delay = Duration(milliseconds: rng.nextInt(600));
      final rotation = rng.nextDouble() * 360;

      return Positioned(
        left: left,
        top: top,
        child: Transform.rotate(
          angle: rotation * 3.14159 / 180,
          child: Container(
            width: size,
            height: size * 0.6,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        )
            .animate()
            .fadeIn(delay: delay, duration: 300.ms)
            .moveY(
              begin: 0,
              end: 600,
              delay: delay,
              duration: Duration(milliseconds: 1500 + rng.nextInt(1000)),
              curve: Curves.easeIn,
            )
            .fadeOut(
              delay: Duration(milliseconds: 1800 + rng.nextInt(500)),
              duration: 400.ms,
            ),
      );
    });
  }
}

class _BrandPreviewCard extends StatelessWidget {
  const _BrandPreviewCard({required this.data});
  final OnboardingData data;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.8,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.all(AppRadius.lg),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.brandName.isNotEmpty ? data.brandName : 'Your Brand',
              style: AppFonts.clashDisplay(
                fontSize: 24,
                color: AppColors.textPrimaryDark,
              ),
            ),
            if (data.selectedColors.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: data.selectedColors.values.map((c) {
                  return Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
            ],
            if (data.selectedFonts.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              ...data.selectedFonts.map((font) {
                TextStyle fontStyle;
                try {
                  fontStyle = GoogleFonts.getFont(
                    font.family,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryDark,
                  );
                } catch (_) {
                  fontStyle = TextStyle(
                    fontFamily: font.family,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryDark,
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text(font.family, style: fontStyle),
                      if (font.label != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          font.label!,
                          style: AppFonts.inter(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],
            if (data.logoFile != null && data.logoFile!.bytes != null) ...[
              const SizedBox(height: AppSpacing.md),
              Image.memory(
                data.logoFile!.bytes!,
                width: 48,
                height: 48,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
