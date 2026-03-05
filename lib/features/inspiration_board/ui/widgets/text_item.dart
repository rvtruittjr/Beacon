import 'package:flutter/material.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../models/inspiration_item_model.dart';

class TextItem extends StatefulWidget {
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
  State<TextItem> createState() => _TextItemState();
}

class _TextItemState extends State<TextItem> {
  bool _hovered = false;
  late TextEditingController _controller;

  String get _text => widget.item.data['text'] as String? ?? 'Text';
  String get _colorHex => widget.item.data['color'] as String? ?? '#FFFFFF';
  double get _fontSize =>
      (widget.item.data['fontSize'] as num?)?.toDouble() ?? 18.0;

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
        child: Stack(
          children: [
            IntrinsicWidth(
              child: EditableText(
                controller: _controller,
                focusNode: FocusNode(),
                style: AppFonts.inter(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.w600,
                  color: _color,
                ),
                cursorColor: _color,
                backgroundCursorColor: Colors.grey,
                maxLines: null,
                onChanged: (val) {
                  widget.onDataChanged({...widget.item.data, 'text': val});
                },
              ),
            ),
            if (_hovered)
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
