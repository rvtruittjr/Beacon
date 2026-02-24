import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/platform_adaptive/adaptive_dialog.dart';
import '../../models/brand_color_model.dart';
import '../../providers/brand_kit_provider.dart';

class ColorPaletteTab extends ConsumerWidget {
  const ColorPaletteTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorsAsync = ref.watch(brandColorsProvider);

    return colorsAsync.when(
      loading: () => const LoadingIndicator(),
      error: (_, __) => const Center(child: Text('Failed to load colors')),
      data: (colors) {
        if (colors.isEmpty) {
          return EmptyState(
            blockColor: AppColors.blockViolet,
            icon: Icons.palette_outlined,
            headline: 'No colors yet',
            supportingText: 'Add your brand colors to keep them organized.',
            ctaLabel: 'Add first color',
            onCtaPressed: () => _showColorDialog(context, ref),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: ReorderableWrap(
                colors: colors,
                onReorder: (oldIndex, newIndex) =>
                    _handleReorder(ref, colors, oldIndex, newIndex),
                onAdd: () => _showColorDialog(context, ref),
                onEdit: (c) => _showColorDialog(context, ref, existing: c),
                onDelete: (c) => _deleteColor(ref, c),
                onCopy: (hex) => _copyHex(context, hex),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showColorDialog(
    BuildContext context,
    WidgetRef ref, {
    BrandColorModel? existing,
  }) {
    AdaptiveDialog.show(
      context: context,
      child: _ColorPickerDialog(
        existing: existing,
        onSave: (hex, label) async {
          final brandId = ref.read(currentBrandProvider);
          if (brandId == null) return;

          if (existing != null) {
            await ref
                .read(colorsRepositoryProvider)
                .updateColor(existing.id, hex: hex, label: label);
          } else {
            await ref
                .read(colorsRepositoryProvider)
                .addColor(brandId: brandId, hex: hex, label: label);
          }
          ref.invalidate(brandColorsProvider);
        },
      ),
    );
  }

  Future<void> _deleteColor(WidgetRef ref, BrandColorModel color) async {
    await ref.read(colorsRepositoryProvider).deleteColor(color.id);
    ref.invalidate(brandColorsProvider);
  }

  Future<void> _handleReorder(
    WidgetRef ref,
    List<BrandColorModel> colors,
    int oldIndex,
    int newIndex,
  ) async {
    final reordered = List<BrandColorModel>.from(colors);
    final item = reordered.removeAt(oldIndex);
    if (newIndex > oldIndex) newIndex--;
    reordered.insert(newIndex, item);

    final orderedIds = reordered.map((c) => c.id).toList();
    await ref.read(colorsRepositoryProvider).reorderColors(orderedIds);
    ref.invalidate(brandColorsProvider);
  }

  void _copyHex(BuildContext context, String hex) {
    Clipboard.setData(ClipboardData(text: hex));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied!'),
        duration: Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        width: 120,
      ),
    );
  }
}

// ─── Reorderable color grid ────────────────────────────────────

class ReorderableWrap extends StatelessWidget {
  const ReorderableWrap({
    super.key,
    required this.colors,
    required this.onReorder,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onCopy,
  });

  final List<BrandColorModel> colors;
  final void Function(int oldIndex, int newIndex) onReorder;
  final VoidCallback onAdd;
  final void Function(BrandColorModel) onEdit;
  final void Function(BrandColorModel) onDelete;
  final void Function(String hex) onCopy;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      proxyDecorator: (child, index, animation) => Material(
        color: Colors.transparent,
        child: child,
      ),
      itemCount: colors.length + 1,
      itemBuilder: (context, index) {
        if (index == colors.length) {
          return _AddSwatchButton(key: const ValueKey('add'), onTap: onAdd);
        }

        final color = colors[index];
        return ReorderableDragStartListener(
          key: ValueKey(color.id),
          index: index,
          child: _ColorSwatchItem(
            color: color,
            onTap: () => onCopy(color.hex),
            onEdit: () => onEdit(color),
            onDelete: () => onDelete(color),
          ),
        );
      },
      onReorder: onReorder,
    );
  }
}

class _ColorSwatchItem extends StatefulWidget {
  const _ColorSwatchItem({
    required this.color,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final BrandColorModel color;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_ColorSwatchItem> createState() => _ColorSwatchItemState();
}

class _ColorSwatchItemState extends State<_ColorSwatchItem> {
  bool _isHovered = false;

  Color get _parsedColor {
    final clean = widget.color.hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onSecondaryTapUp: (details) => _showContextMenu(context, details),
        onLongPress: () => _showContextMenuMobile(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: SizedBox(
            height: 64,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _parsedColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 1,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.color.label ?? 'Unnamed',
                        style: AppFonts.inter(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.color.hex.toUpperCase(),
                        style:
                            AppFonts.inter(fontSize: 12, color: mutedColor),
                      ),
                    ],
                  ),
                ),
                if (_isHovered) ...[
                  IconButton(
                    icon:
                        Icon(Icons.edit_outlined, size: 18, color: mutedColor),
                    onPressed: widget.onEdit,
                  ),
                  IconButton(
                    icon: Icon(
                        Icons.delete_outline, size: 18, color: mutedColor),
                    onPressed: widget.onDelete,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, TapUpDetails details) {
    _showMenu(context, details.globalPosition);
  }

  void _showContextMenuMobile(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final position = box.localToGlobal(Offset.zero) + Offset(box.size.width / 2, box.size.height);
    _showMenu(context, position);
  }

  void _showMenu(BuildContext context, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    ).then((value) {
      if (value == 'edit') widget.onEdit();
      if (value == 'delete') widget.onDelete();
    });
  }
}

class _AddSwatchButton extends StatelessWidget {
  const _AddSwatchButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: SizedBox(
          height: 64,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: mutedColor,
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: Icon(Icons.add, color: mutedColor, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Add color',
                style: AppFonts.inter(fontSize: 14, color: mutedColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Color picker dialog ────────────────────────────────────────

class _ColorPickerDialog extends StatefulWidget {
  const _ColorPickerDialog({this.existing, required this.onSave});

  final BrandColorModel? existing;
  final Future<void> Function(String hex, String? label) onSave;

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late final TextEditingController _hexController;
  late final TextEditingController _labelController;
  Color _preview = AppColors.blockViolet;
  bool _saving = false;

  static const _presetColors = [
    Color(0xFF6C63FF),
    Color(0xFFFF6B6B),
    Color(0xFFC8F135),
    Color(0xFFFFD166),
    Color(0xFF22C55E),
    Color(0xFF1DA1F2),
    Color(0xFFE1306C),
    Color(0xFF1A1A1A),
    Color(0xFFFFFFFF),
    Color(0xFF0D0D2B),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
    Color(0xFF3B82F6),
    Color(0xFFEF4444),
    Color(0xFF10B981),
    Color(0xFFA855F7),
    Color(0xFF64748B),
  ];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _hexController = TextEditingController(
      text: existing?.hex ?? '',
    );
    _labelController = TextEditingController(
      text: existing?.label ?? '',
    );
    if (existing != null) {
      _preview = _parseHex(existing.hex);
    }
  }

  @override
  void dispose() {
    _hexController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Color _parseHex(String hex) {
    final clean = hex.replaceFirst('#', '');
    if (clean.length == 6 && RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(clean)) {
      return Color(int.parse('FF$clean', radix: 16));
    }
    return AppColors.blockViolet;
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.existing != null ? 'Edit Color' : 'Add Color',
            style: AppFonts.clashDisplay(fontSize: 24, color: textColor),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Color grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presetColors.map((c) {
              final isSelected = c.value == _preview.value;
              return GestureDetector(
                onTap: () {
                  setState(() => _preview = c);
                  _hexController.text = _colorToHex(c);
                },
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
                            width: 1,
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
                      setState(() => _preview = color);
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _preview,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                    width: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Label input
          TextField(
            controller: _labelController,
            decoration: const InputDecoration(
              labelText: 'Label (optional)',
              hintText: 'e.g. Primary, Accent',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: widget.existing != null ? 'Save' : 'Add',
            isLoading: _saving,
            onPressed: _saving ? null : _save,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final hex = _hexController.text.trim();
    if (hex.isEmpty) return;

    final normalizedHex =
        hex.startsWith('#') ? hex : '#$hex';

    setState(() => _saving = true);
    try {
      await widget.onSave(
        normalizedHex.toUpperCase(),
        _labelController.text.trim().isEmpty
            ? null
            : _labelController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
