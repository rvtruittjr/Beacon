import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/config/design_tokens.dart';
import '../../../core/config/app_fonts.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/platform_adaptive/adaptive_dialog.dart';
import '../../audience/providers/audience_provider.dart';
import '../../content_pillars/data/content_pillar_repository.dart';
import '../../content_pillars/providers/content_pillar_provider.dart' show contentPillarsListProvider;
import '../../voice_tone/providers/voice_provider.dart';
import '../models/brand_kit_template.dart';
import '../providers/brand_kit_provider.dart';
import '../services/template_service.dart';
import 'widgets/color_palette_tab.dart';
import 'widgets/font_tab.dart';
import 'widgets/logo_tab.dart';
import 'widgets/template_picker.dart';

class BrandKitScreen extends ConsumerWidget {
  const BrandKitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              0,
            ),
            child: Row(
              children: [
                Text(
                  'Brand Kit',
                  style: AppFonts.clashDisplay(fontSize: 32, color: textColor),
                ),
                const Spacer(),
                AppButton(
                  label: 'Template',
                  icon: LucideIcons.layoutTemplate,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => _showTemplatePicker(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: TabBar(
              labelColor: textColor,
              unselectedLabelColor: mutedColor,
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.only(right: AppSpacing.lg),
              labelStyle: AppFonts.inter(
                fontSize: 14,
                color: textColor,
              ).copyWith(fontWeight: FontWeight.w600),
              unselectedLabelStyle: AppFonts.inter(
                fontSize: 14,
                color: mutedColor,
              ),
              tabs: const [
                Tab(text: 'Colors'),
                Tab(text: 'Fonts'),
                Tab(text: 'Logos'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                ColorPaletteTab(),
                FontTab(),
                LogoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTemplatePicker(BuildContext context, WidgetRef ref) {
    AdaptiveDialog.show(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 520),
          child: SingleChildScrollView(
            child: TemplatePicker(
              onSelected: (template) async {
                final brandId = ref.read(currentBrandProvider);
                if (brandId == null) return;

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Applying template...')),
                );

                final service = TemplateService(
                  colorsRepo: ref.read(colorsRepositoryProvider),
                  fontsRepo: ref.read(fontsRepositoryProvider),
                  voiceRepo: ref.read(voiceRepositoryProvider),
                  audienceRepo: ref.read(audienceRepositoryProvider),
                  pillarRepo: ref.read(contentPillarRepositoryProvider),
                );

                try {
                  await service.applyTemplate(brandId, template);
                  ref.invalidate(brandColorsProvider);
                  ref.invalidate(brandFontsProvider);
                  ref.invalidate(voiceProvider);
                  ref.invalidate(audienceProvider);
                  ref.invalidate(contentPillarsListProvider);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Template applied!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to apply template: $e')),
                    );
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
