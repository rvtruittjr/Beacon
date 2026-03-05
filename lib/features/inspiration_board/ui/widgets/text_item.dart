import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../models/inspiration_item_model.dart';
import '../../providers/tool_state_provider.dart';

class TextItem extends ConsumerStatefulWidget {
  const TextItem({
    super.key,
    required this.item,
    required this.onMoved,
    required this.onDragEnd,
    required this.onDelete,
    required this.onDataChanged,
  });

  final InspirationItemModel item;
  final void Function(double dx, double dy) onMoved;
  final VoidCallback onDragEnd;
  final VoidCallback onDelete;
  final void Function(Map<String, dynamic> data) onDataChanged;

  @override
  ConsumerState<TextItem> createState() => _TextItemState();
}

class _TextItemState extends ConsumerState<TextItem> {
  bool _hovered = false;
  bool _isEditing = false;
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  String get _text => widget.item.data['text'] as String? ?? 'Text';
  String get _colorHex => widget.item.data['color'] as String? ?? '#FFFFFF';
  double get _fontSize =>
      (widget.item.data['fontSize'] as num?)?.toDouble() ?? 18.0;
  FontWeight get _fontWeight =>
      (widget.item.data['fontWeight'] as String?) == 'bold'
          ? FontWeight.w700
          : FontWeight.w600;
  FontStyle get _fontStyle =>
      (widget.item.data['fontStyle'] as String?) == 'italic'
          ? FontStyle.italic
          : FontStyle.normal;
  TextAlign get _textAlign => switch (widget.item.data['textAlign'] as String?) {
        'center' => TextAlign.center,
        'right' => TextAlign.right,
        _ => TextAlign.left,
      };

  Color get _color {
    final clean = _colorHex.replaceFirst('#', '');
    if (clean.length == 6) {
      return Color(0xFF000000 | int.parse(clean, radix: 16));
    }
    return const Color(0xFFFFFFFF);
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _text);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        ref.read(selectedItemProvider.notifier).state = widget.item.id;
      } else if (_isEditing) {
        setState(() => _isEditing = false);
      }
    });
  }

  @override
  void didUpdateWidget(TextItem old) {
    super.didUpdateWidget(old);
    if (old.item.data['text'] != widget.item.data['text'] &&
        widget.item.data['text'] != _controller.text) {
      _controller.text = _text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _showHandles {
    final selected = ref.watch(selectedItemProvider);
    return _hovered || selected == widget.item.id;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final textStyle = AppFonts.inter(
      fontSize: _fontSize,
      fontWeight: _fontWeight,
      color: _color,
    ).copyWith(fontStyle: _fontStyle);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onPanUpdate: _isEditing ? null : (d) => widget.onMoved(d.delta.dx, d.delta.dy),
        onPanEnd: _isEditing ? null : (_) => widget.onDragEnd(),
        onDoubleTap: () {
          setState(() => _isEditing = true);
          _focusNode.requestFocus();
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Selection border
            if (_showHandles)
              Positioned(
                left: -4,
                right: -4,
                top: -4,
                bottom: -4,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: primary, width: 2),
                      borderRadius: BorderRadius.all(AppRadius.sm),
                    ),
                  ),
                ),
              ),
            IntrinsicWidth(
              child: _isEditing
                  ? TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: textStyle,
                      cursorColor: _color,
                      maxLines: null,
                      textAlign: _textAlign,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (val) {
                        widget.onDataChanged({...widget.item.data, 'text': val});
                      },
                    )
                  : ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 40),
                      child: Text(
                        _text,
                        style: textStyle,
                        textAlign: _textAlign,
                      ),
                    ),
            ),
            if (_showHandles)
              Positioned(
                top: -8,
                right: -8,
                child: GestureDetector(
                  onTap: widget.onDelete,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 12, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
