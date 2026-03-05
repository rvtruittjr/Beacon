import 'package:flutter/material.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../models/inspiration_item_model.dart';

class StickyNoteItem extends StatefulWidget {
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
  State<StickyNoteItem> createState() => _StickyNoteItemState();
}

class _StickyNoteItemState extends State<StickyNoteItem> {
  bool _hovered = false;
  late TextEditingController _controller;

  String get _text => widget.item.data['text'] as String? ?? '';
  String get _bgHex => widget.item.data['bgColor'] as String? ?? '#FFEB3B';

  Color get _bgColor {
    final clean = _bgHex.replaceFirst('#', '');
    if (clean.length == 6) {
      return Color(0xFF000000 | int.parse(clean, radix: 16));
    }
    return const Color(0xFFFFEB3B);
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onPanUpdate: (d) => widget.onMoved(d.delta.dx, d.delta.dy),
        onPanEnd: (_) => widget.onDragEnd(),
        child: Container(
          width: widget.item.width,
          height: widget.item.height,
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.all(AppRadius.md),
            boxShadow: AppShadows.md,
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: EditableText(
                  controller: _controller,
                  focusNode: FocusNode(),
                  style: AppFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  cursorColor: Colors.black54,
                  backgroundCursorColor: Colors.grey,
                  maxLines: null,
                  onChanged: (val) {
                    widget.onDataChanged({...widget.item.data, 'text': val});
                  },
                ),
              ),
              if (_hovered)
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
                      child: const Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              if (_hovered)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onPanUpdate: (d) =>
                        widget.onResized(d.delta.dx, d.delta.dy),
                    onPanEnd: (_) => widget.onResizeEnd(),
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                        ),
                      ),
                      child: const Icon(Icons.drag_handle, size: 12, color: Colors.white),
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
