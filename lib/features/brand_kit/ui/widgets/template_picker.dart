import 'package:flutter/material.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../data/brand_kit_templates.dart';
import '../../models/brand_kit_template.dart';

class TemplatePicker extends StatefulWidget {
  const TemplatePicker({
    super.key,
    required this.onSelected,
    this.onSkip,
  });

  final void Function(BrandKitTemplate template) onSelected;
  final VoidCallback? onSkip;

  @override
  State<TemplatePicker> createState() => _TemplatePickerState();
}

class _TemplatePickerState extends State<TemplatePicker> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Start with a template',
          style: AppFonts.clashDisplay(fontSize: 24, color: textColor),
        ),
        const SizedBox(height: 4),
        Text(
          'Pick a starting point — you can customize everything later.',
          style: AppFonts.inter(fontSize: 13, color: mutedColor),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...List.generate(kBrandKitTemplates.length, (index) {
          final template = kBrandKitTemplates[index];
          final isSelected = _selectedIndex == index;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _TemplateCard(
              template: template,
              isSelected: isSelected,
              onTap: () => setState(() => _selectedIndex = index),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.md),
        FilledButton(
          onPressed: _selectedIndex != null
              ? () => widget.onSelected(kBrandKitTemplates[_selectedIndex!])
              : null,
          child: const Text('Apply template'),
        ),
        if (widget.onSkip != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: TextButton(
              onPressed: widget.onSkip,
              child: Text(
                'Skip — start from scratch',
                style: AppFonts.inter(fontSize: 13, color: mutedColor),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  final BrandKitTemplate template;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final borderColor = isSelected
        ? theme.colorScheme.primary
        : (isDark ? AppColors.borderDark : AppColors.borderLight);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceMidDark : AppColors.surfaceMidLight,
          borderRadius: BorderRadius.all(AppRadius.md),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(template.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: AppFonts.inter(
                      fontSize: 14,
                      color: textColor,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    template.description,
                    style: AppFonts.inter(fontSize: 12, color: mutedColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Color preview
                  Row(
                    children: [
                      ...template.colors.map((c) {
                        final hex = c.hex.replaceFirst('#', '');
                        final color = Color(int.parse('FF$hex', radix: 16));
                        return Container(
                          width: 16,
                          height: 16,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                              width: 0.5,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        template.fonts.map((f) => f.family).join(' + '),
                        style: AppFonts.inter(fontSize: 11, color: mutedColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
