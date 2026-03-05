import 'package:flutter/material.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';

class ColorPickerField extends StatefulWidget {
  const ColorPickerField({
    super.key,
    required this.label,
    required this.hex,
    required this.onChanged,
    this.showAuto = false,
    this.isAuto = false,
    this.onAutoToggled,
  });

  final String label;
  final String hex;
  final ValueChanged<String> onChanged;
  final bool showAuto;
  final bool isAuto;
  final VoidCallback? onAutoToggled;

  @override
  State<ColorPickerField> createState() => _ColorPickerFieldState();
}

class _ColorPickerFieldState extends State<ColorPickerField> {
  late TextEditingController _controller;
  bool _showGrid = false;

  static const _presetColors = [
    '#6C63FF', '#FF6B6B', '#C8F135', '#FFD166',
    '#1DA1F2', '#14B8A6', '#F59E0B', '#EF4444',
    '#22C55E', '#8B5CF6', '#EC4899', '#06B6D4',
    '#FFFFFF', '#F2F2F8', '#1A1A2E', '#000000',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.hex);
  }

  @override
  void didUpdateWidget(ColorPickerField old) {
    super.didUpdateWidget(old);
    if (old.hex != widget.hex && _controller.text != widget.hex) {
      _controller.text = widget.hex;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color? _parseHex(String hex) {
    final clean = hex.replaceFirst('#', '');
    if (clean.length == 6 && RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(clean)) {
      return Color(0xFF000000 | int.parse(clean, radix: 16));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    final currentColor = _parseHex(widget.hex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: AppFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            if (widget.showAuto) ...[
              const Spacer(),
              GestureDetector(
                onTap: widget.onAutoToggled,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isAuto ? Icons.check_box : Icons.check_box_outline_blank,
                      size: 16,
                      color: mutedColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Auto',
                      style: AppFonts.inter(fontSize: 11, color: mutedColor),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _showGrid = !_showGrid),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: currentColor ?? Colors.grey,
                  borderRadius: BorderRadius.all(AppRadius.sm),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SizedBox(
                height: 32,
                child: TextField(
                  controller: _controller,
                  style: AppFonts.inter(fontSize: 13, color: textColor),
                  decoration: InputDecoration(
                    hintText: '#6C63FF',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 0,
                    ),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(AppRadius.sm),
                    ),
                  ),
                  enabled: !widget.isAuto,
                  onSubmitted: (val) {
                    final hex = val.startsWith('#') ? val : '#$val';
                    if (_parseHex(hex) != null) {
                      widget.onChanged(hex);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        if (_showGrid && !widget.isAuto) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _presetColors.map((hex) {
              final c = _parseHex(hex)!;
              final isSelected = widget.hex.toUpperCase() == hex.toUpperCase();
              return GestureDetector(
                onTap: () {
                  widget.onChanged(hex);
                  _controller.text = hex;
                  setState(() => _showGrid = false);
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.all(AppRadius.xs),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : (isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
