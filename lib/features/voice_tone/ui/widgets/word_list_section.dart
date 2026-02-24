import 'package:flutter/material.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';

class WordListSection extends StatelessWidget {
  const WordListSection({
    super.key,
    required this.wordsWeUse,
    required this.wordsWeAvoid,
    required this.onAddWeUse,
    required this.onRemoveWeUse,
    required this.onAddWeAvoid,
    required this.onRemoveWeAvoid,
  });

  final List<String> wordsWeUse;
  final List<String> wordsWeAvoid;
  final ValueChanged<String> onAddWeUse;
  final ValueChanged<String> onRemoveWeUse;
  final ValueChanged<String> onAddWeAvoid;
  final ValueChanged<String> onRemoveWeAvoid;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _WordColumn(
            title: 'We say',
            words: wordsWeUse,
            chipColor: AppColors.blockLime,
            chipTextColor: AppColors.textOnLime,
            onAdd: onAddWeUse,
            onRemove: onRemoveWeUse,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: _WordColumn(
            title: "We don't say",
            words: wordsWeAvoid,
            chipColor: AppColors.blockCoral,
            chipTextColor: AppColors.textOnCoral,
            onAdd: onAddWeAvoid,
            onRemove: onRemoveWeAvoid,
          ),
        ),
      ],
    );
  }
}

class _WordColumn extends StatefulWidget {
  const _WordColumn({
    required this.title,
    required this.words,
    required this.chipColor,
    required this.chipTextColor,
    required this.onAdd,
    required this.onRemove,
  });

  final String title;
  final List<String> words;
  final Color chipColor;
  final Color chipTextColor;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  @override
  State<_WordColumn> createState() => _WordColumnState();
}

class _WordColumnState extends State<_WordColumn> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final word = _controller.text.trim();
    if (word.isEmpty) return;
    widget.onAdd(word);
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
          widget.title,
          style: AppFonts.inter(fontSize: 12, color: mutedColor)
              .copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Type + Enter',
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
          children: widget.words.map((word) {
            return _WordChip(
              word: word,
              bgColor: widget.chipColor,
              textColor: widget.chipTextColor,
              onDelete: () => widget.onRemove(word),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _WordChip extends StatefulWidget {
  const _WordChip({
    required this.word,
    required this.bgColor,
    required this.textColor,
    required this.onDelete,
  });

  final String word;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onDelete;

  @override
  State<_WordChip> createState() => _WordChipState();
}

class _WordChipState extends State<_WordChip> {
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
                widget.word,
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
