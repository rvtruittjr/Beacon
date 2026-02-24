import 'package:flutter/material.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';

class ArchetypeSelector {
  ArchetypeSelector._();

  static const _archetypes = [
    ('The Creator', 'Innovative, expressive, and imaginative.'),
    ('The Rebel', 'Disruptive, bold, and unapologetic.'),
    ('The Hero', 'Courageous, determined, and inspiring.'),
    ('The Sage', 'Wise, thoughtful, and knowledge-driven.'),
    ('The Explorer', 'Adventurous, curious, and freedom-seeking.'),
    ('The Entertainer', 'Fun, energetic, and light-hearted.'),
    ('The Advocate', 'Passionate, empathetic, and mission-driven.'),
    ('The Specialist', 'Expert, precise, and authoritative.'),
  ];

  static void show(BuildContext context, ValueChanged<String> onSelect) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final surfaceColor =
        isDark ? AppColors.surfaceMidDark : AppColors.surfaceMidLight;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: AppRadius.lg),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: mutedColor,
                    borderRadius: BorderRadius.all(AppRadius.full),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Choose your archetype',
                style: AppFonts.clashDisplay(
                    fontSize: 24, color: textColor),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1.6,
                  ),
                  itemCount: _archetypes.length,
                  itemBuilder: (ctx, index) {
                    final (name, desc) = _archetypes[index];
                    return GestureDetector(
                      onTap: () {
                        onSelect(name);
                        Navigator.of(ctx).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius:
                              BorderRadius.all(AppRadius.md),
                          border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(
                              name,
                              style: AppFonts.clashDisplay(
                                fontSize: 18,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              desc,
                              style: AppFonts.inter(
                                fontSize: 12,
                                color: mutedColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
