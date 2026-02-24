import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../shared/widgets/app_card.dart';

class ColorPaletteSection extends StatelessWidget {
  const ColorPaletteSection({super.key, required this.colors});
  final List<Map<String, dynamic>> colors;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.feature,
      blockColor: AppColors.blockViolet,
      headerTitle: 'Brand Colors',
      child: colors.isEmpty
          ? _InlineEmpty(type: 'colors')
          : Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: colors.map((c) {
                final hex = c['hex'] as String;
                final label = c['label'] as String? ?? '';
                final color = _parseHex(hex);

                return _ColorCircle(
                  color: color,
                  hex: hex,
                  label: label,
                );
              }).toList(),
            ),
    );
  }

  static Color _parseHex(String hex) {
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}

class _ColorCircle extends StatefulWidget {
  const _ColorCircle({
    required this.color,
    required this.hex,
    required this.label,
  });

  final Color color;
  final String hex;
  final String label;

  @override
  State<_ColorCircle> createState() => _ColorCircleState();
}

class _ColorCircleState extends State<_ColorCircle> {
  bool _showCopied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.hex));
    setState(() => _showCopied = true);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _showCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: '${widget.label} ${widget.hex}',
      child: GestureDetector(
        onTap: _copy,
        child: SizedBox(
          width: 56,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.sm,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedSwitcher(
                duration: 200.ms,
                child: _showCopied
                    ? Text(
                        'Copied!',
                        key: const ValueKey('copied'),
                        style: AppFonts.inter(
                          fontSize: 10,
                          color: AppColors.success,
                        ),
                      )
                        .animate()
                        .fadeIn(duration: 200.ms)
                        .then(delay: 1500.ms)
                        .fadeOut(duration: 300.ms)
                    : Text(
                        widget.label,
                        key: const ValueKey('label'),
                        style: AppFonts.inter(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.mutedDark
                              : AppColors.mutedLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Row(
      children: [
        Text(
          'No $type added yet.',
          style: AppFonts.inter(fontSize: 14, color: mutedColor)
              .copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(width: AppSpacing.sm),
        TextButton(
          onPressed: () => context.go('/app/brand-kit'),
          child: Text(
            'Add',
            style: AppFonts.inter(fontSize: 14, color: mutedColor),
          ),
        ),
      ],
    );
  }
}
