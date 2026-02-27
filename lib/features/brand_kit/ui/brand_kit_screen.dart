import 'package:flutter/material.dart';

import '../../../core/config/design_tokens.dart';
import '../../../core/config/app_fonts.dart';
import 'widgets/color_palette_tab.dart';
import 'widgets/font_tab.dart';
import 'widgets/logo_tab.dart';

class BrandKitScreen extends StatelessWidget {
  const BrandKitScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: Text(
              'Brand Kit',
              style: AppFonts.clashDisplay(fontSize: 32, color: textColor),
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
}
