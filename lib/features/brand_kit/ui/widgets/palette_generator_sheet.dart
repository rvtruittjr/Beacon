import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../providers/brand_kit_provider.dart';
import '../../services/palette_generator.dart';

class PaletteGeneratorSheet extends ConsumerStatefulWidget {
  const PaletteGeneratorSheet({super.key});

  @override
  ConsumerState<PaletteGeneratorSheet> createState() =>
      _PaletteGeneratorSheetState();
}

class _PaletteGeneratorSheetState
    extends ConsumerState<PaletteGeneratorSheet> {
  final _hexController = TextEditingController(text: '#6C63FF');
  Color _primary = const Color(0xFF6C63FF);
  Map<String, List<Color>> _palettes = {};
  final Set<String> _adding = {};

  static const _presetColors = [
    Color(0xFF6C63FF),
    Color(0xFFFF6B6B),
    Color(0xFFC8F135),
    Color(0xFFFFD166),
    Color(0xFF22C55E),
    Color(0xFF1DA1F2),
    Color(0xFFE1306C),
    Color(0xFF0D0D2B),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
  ];

  @override
  void initState() {
    super.initState();
    _palettes = PaletteGenerator.generate(_primary);
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  Color _parseHex(String hex) {
    final clean = hex.replaceFirst('#', '');
    if (clean.length == 6 && RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(clean)) {
      return Color(int.parse('FF$clean', radix: 16));
    }
    return _primary;
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _updatePrimary(Color color) {
    setState(() {
      _primary = color;
      _hexController.text = _colorToHex(color);
      _palettes = PaletteGenerator.generate(color);
    });
  }

  Future<void> _addPalette(String name, List<Color> colors) async {
    final brandId = ref.read(currentBrandProvider);
    if (brandId == null) return;

    setState(() => _adding.add(name));
    try {
      final repo = ref.read(colorsRepositoryProvider);
      for (final color in colors) {
        final hex = _colorToHex(color);
        await repo.addColor(brandId: brandId, hex: hex);
      }
      ref.invalidate(brandColorsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${colors.length} colors from $name'),
            behavior: SnackBarBehavior.floating,
            width: 280,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _adding.remove(name));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Generate Palette',
              style: AppFonts.clashDisplay(fontSize: 24, color: textColor),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Pick a base color to generate harmonious palettes.',
              style: AppFonts.inter(fontSize: 13, color: mutedColor),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Preset swatches
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetColors.map((c) {
                final isSelected = c.value == _primary.value;
                return GestureDetector(
                  onTap: () => _updatePrimary(c),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: textColor, width: 3)
                          : Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),

            // Hex input + preview
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hexController,
                    decoration: const InputDecoration(
                      labelText: 'Hex color',
                      hintText: '#FF5733',
                    ),
                    onChanged: (value) {
                      final color = _parseHex(value);
                      if (value.replaceFirst('#', '').length == 6) {
                        setState(() {
                          _primary = color;
                          _palettes = PaletteGenerator.generate(color);
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // Generated palettes
            ..._palettes.entries.map((entry) => _PaletteRow(
                  name: entry.key,
                  colors: entry.value,
                  isAdding: _adding.contains(entry.key),
                  onAdd: () => _addPalette(entry.key, entry.value),
                  textColor: textColor,
                  mutedColor: mutedColor,
                  isDark: isDark,
                )),
          ],
        ),
      ),
    );
  }
}

class _PaletteRow extends StatelessWidget {
  const _PaletteRow({
    required this.name,
    required this.colors,
    required this.isAdding,
    required this.onAdd,
    required this.textColor,
    required this.mutedColor,
    required this.isDark,
  });

  final String name;
  final List<Color> colors;
  final bool isAdding;
  final VoidCallback onAdd;
  final Color textColor;
  final Color mutedColor;
  final bool isDark;

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: AppFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              AppButton(
                label: 'Add',
                icon: Icons.add,
                variant: AppButtonVariant.ghost,
                isLoading: isAdding,
                onPressed: isAdding ? null : onAdd,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: colors.map((c) {
              return Tooltip(
                message: _colorToHex(c),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.all(AppRadius.sm),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
