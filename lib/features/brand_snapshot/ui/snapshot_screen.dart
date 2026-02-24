import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/config/design_tokens.dart';
import '../../../core/config/app_fonts.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_state.dart';
import '../../brands/ui/create_brand_screen.dart';
import '../providers/snapshot_provider.dart';
import 'widgets/snapshot_header.dart';
import 'widgets/color_palette_section.dart';
import 'widgets/typography_section.dart';
import 'widgets/logo_variations_section.dart';
import 'widgets/brand_voice_section.dart';
import 'widgets/audience_section.dart';
import 'widgets/content_pillars_section.dart';
import 'widgets/top_content_section.dart';

class SnapshotScreen extends ConsumerWidget {
  const SnapshotScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandId = ref.watch(currentBrandProvider);

    // No brand selected — prompt to create one
    if (brandId == null) {
      return _NoBrandView();
    }

    final snapshot = ref.watch(snapshotProvider);

    return snapshot.when(
      loading: () => const LoadingIndicator(caption: 'Loading snapshot…'),
      error: (error, _) => ErrorState(
        message: 'Could not load your brand snapshot.',
        onRetry: () => ref.invalidate(snapshotProvider),
      ),
      data: (data) {
        final sections = <Widget>[
          SnapshotHeader(brand: data.brand),
          ColorPaletteSection(colors: data.colors),
          TypographySection(fonts: data.fonts),
          LogoVariationsSection(logos: data.logos),
          BrandVoiceSection(voice: data.voice),
          AudienceSection(audience: data.audience),
          ContentPillarsSection(pillars: data.pillars),
          TopContentSection(items: data.topContent),
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.x2l,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < sections.length; i++) ...[
                    sections[i]
                        .animate()
                        .fadeIn(
                          delay: (80 * i).ms,
                          duration: 350.ms,
                          curve: Curves.easeOut,
                        )
                        .moveY(
                          begin: 12,
                          end: 0,
                          delay: (80 * i).ms,
                          duration: 350.ms,
                          curve: Curves.easeOut,
                        ),
                    if (i < sections.length - 1)
                      const SizedBox(height: AppSpacing.lg),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NoBrandView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x2l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.blockYellow.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.sparkles,
                size: 36,
                color: AppColors.blockYellow,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Welcome to Beacøn',
              style: AppFonts.clashDisplay(fontSize: 32, color: textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Create your first brand kit to get started.',
              style: AppFonts.inter(fontSize: 16, color: mutedColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Create your brand',
              icon: LucideIcons.plus,
              onPressed: () => CreateBrandScreen.show(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
