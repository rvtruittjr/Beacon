import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../models/inspiration_item_model.dart';
import '../../providers/tool_state_provider.dart';

class StickyNoteItem extends ConsumerStatefulWidget {
  const StickyNoteItem({
    super.key,
    required this.item,
    required this.onMoved,
    required this.onDragEnd,
    required this.onResized,
    required this.onResizeEnd,
    required this.onDelete,
    required this.onDataChanged,
  });

  final InspirationItemModel item;
  final void Function(double dx, double dy) onMoved;
  final VoidCallback onDragEnd;
  final void Function(double dw, double dh) onResized;
  final VoidCallback onResizeEnd;
  final VoidCallback onDelete;
  final void Function(Map<String, dynamic> data) onDataChanged;

  @override
  ConsumerState<StickyNoteItem> createState() => _StickyNoteItemState();
}

class _StickyNoteItemState extends ConsumerState<StickyNoteItem> {
  bool _hovered = false;
  bool _isEditing = false;
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  String get _text => widget.item.data['text'] as String? ?? '';
  String get _bgHex => widget.item.data['bgColor'] as String? ?? '#FFEB3B';
  String get _textColorHex =>
      widget.item.data['textColor'] as String? ?? '#000000';
  double get _fontSize =>
      (widget.item.data['fontSize'] as num?)?.toDouble() ?? 14.0;
  FontWeight get _fontWeight =>
      (widget.item.data['fontWeight'] as String?) == 'bold'
          ? FontWeight.bold
          : FontWeight.w500;
  FontStyle get _fontStyle =>
      (widget.item.data['fontStyle'] as String?) == 'italic'
          ? FontStyle.italic
          : FontStyle.normal;

  Color _hexToColor(String hex, Color fallback) {
    final clean = hex.replaceFirst('#', '');
    if (clean.length == 6) {
      return Color(0xFF000000 | int.parse(clean, radix: 16));
    }
    return fallback;
  }

  Color get _bgColor => _hexToColor(_bgHex, const Color(0xFFFFEB3B));
  Color get _textColor => _hexToColor(_textColorHex, const Color(0xFF000000));

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
  void didUpdateWidget(StickyNoteItem old) {
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
      color: _textColor,
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
        child: Container(
          width: widget.item.width,
          height: widget.item.height,
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.all(AppRadius.md),
            boxShadow: AppShadows.md,
            border: _showHandles
                ? Border.all(color: primary, width: 2)
                : null,
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: _isEditing
                    ? TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        style: textStyle,
                        cursorColor: _textColor.withValues(alpha: 0.7),
                        maxLines: null,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (val) {
                          widget.onDataChanged(
                              {...widget.item.data, 'text': val});
                        },
                      )
                    : Text(
                        _text.isEmpty ? 'Double-tap to type' : _text,
                        style: _text.isEmpty
                            ? textStyle.copyWith(
                                color: _textColor.withValues(alpha: 0.4))
                            : textStyle,
                        maxLines: null,
                      ),
              ),
              if (_showHandles)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: widget.onDelete,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ),
              if (_showHandles)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (d) =>
                        widget.onResized(d.delta.dx, d.delta.dy),
                    onPanEnd: (_) => widget.onResizeEnd(),
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                            ),
                          ),
                          child: const Icon(Icons.drag_handle,
                              size: 10, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
