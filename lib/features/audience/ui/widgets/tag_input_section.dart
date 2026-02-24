import 'package:flutter/material.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';

class TagInputSection extends StatefulWidget {
  const TagInputSection({
    super.key,
    required this.label,
    required this.hintText,
    required this.chipColor,
    required this.chipTextColor,
    required this.values,
    required this.onAdd,
    required this.onRemove,
  });

  final String label;
  final String hintText;
  final Color chipColor;
  final Color chipTextColor;
  final List<String> values;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  @override
  State<TagInputSection> createState() => _TagInputSectionState();
}

class _TagInputSectionState extends State<TagInputSection> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    widget.onAdd(value);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppFonts.inter(fontSize: 11, color: mutedColor)
              .copyWith(fontWeight: FontWeight.w600, letterSpacing: 1),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: mutedColor, fontSize: 13),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 10,
            ),
          ),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: widget.values.map((value) {
            return _TagChip(
              label: value,
              bgColor: widget.chipColor,
              textColor: widget.chipTextColor,
              onDelete: () => widget.onRemove(value),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TagChip extends StatefulWidget {
  const _TagChip({
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.onDelete,
  });

  final String label;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onDelete;

  @override
  State<_TagChip> createState() => _TagChipState();
}

class _TagChipState extends State<_TagChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onDelete,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.all(AppRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_hovered) ...[
                const SizedBox(width: 4),
                Icon(Icons.close, size: 14, color: widget.textColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
