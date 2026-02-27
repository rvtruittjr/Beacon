import 'dart:html' as html;

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
import 'widgets/social_accounts_snapshot.dart';
import 'widgets/brand_health_card.dart';
import '../models/brand_health_score.dart';
import '../services/pdf_export_service.dart';

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
        final healthScore = BrandHealthScore.fromSnapshotData(data);
        final isWide = MediaQuery.sizeOf(context).width > 900;

        if (!isWide) {
          return _buildMobileLayout(context, data, healthScore);
        }
        return _buildDesktopLayout(context, data, healthScore);
      },
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    SnapshotData data,
    BrandHealthScore healthScore,
  ) {
    final sections = <Widget>[
      SnapshotHeader(
        brand: data.brand,
        onExportPdf: () => _exportPdf(context, data),
      ),
      BrandHealthCard(score: healthScore),
      ColorPaletteSection(colors: data.colors),
      TypographySection(fonts: data.fonts),
      LogoVariationsSection(logos: data.logos),
      BrandVoiceSection(voice: data.voice),
      AudienceSection(audience: data.audience),
      SocialAccountsSnapshot(accounts: data.socialAccounts),
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
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    SnapshotData data,
    BrandHealthScore healthScore,
  ) {
    Widget animateRow(Widget child, int index) {
      return child
          .animate()
          .fadeIn(
            delay: (100 * index).ms,
            duration: 350.ms,
            curve: Curves.easeOut,
          )
          .moveY(
            begin: 12,
            end: 0,
            delay: (100 * index).ms,
            duration: 350.ms,
            curve: Curves.easeOut,
          );
    }

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
              // Row 0: Header (full width)
              animateRow(
                SnapshotHeader(
                  brand: data.brand,
                  onExportPdf: () => _exportPdf(context, data),
                ),
                0,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Row 1: Health + Colors (1/2 + 1/2)
              animateRow(
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: BrandHealthCard(score: healthScore)),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: ColorPaletteSection(colors: data.colors)),
                    ],
                  ),
                ),
                1,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Row 2: Typography + Logos (1/2 + 1/2)
              animateRow(
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: TypographySection(fonts: data.fonts)),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: LogoVariationsSection(logos: data.logos)),
                    ],
                  ),
                ),
                2,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Row 3: Voice + Audience (1/2 + 1/2)
              animateRow(
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: BrandVoiceSection(voice: data.voice)),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                          child: AudienceSection(audience: data.audience)),
                    ],
                  ),
                ),
                3,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Row 4: Social Accounts (full width)
              animateRow(
                SocialAccountsSnapshot(accounts: data.socialAccounts),
                4,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Row 5: Pillars (1/3) + Top Content (2/3)
              animateRow(
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 1,
                        child: ContentPillarsSection(pillars: data.pillars),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        flex: 2,
                        child: TopContentSection(items: data.topContent),
                      ),
                    ],
                  ),
                ),
                5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _exportPdf(BuildContext context, SnapshotData data) async {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Generating PDF...')),
  );

  try {
    final bytes = await PdfExportService.generate(data);
    final fileName = '${data.brand.name} - Brand Guidelines.pdf';

    // Use browser download instead of Printing.layoutPdf (not supported on web)
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF downloaded!')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate PDF: $e')),
      );
    }
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
