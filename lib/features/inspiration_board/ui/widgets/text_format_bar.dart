import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/config/design_tokens.dart';
import '../../models/inspiration_item_model.dart';
import '../../providers/tool_state_provider.dart';

/// Floating format bar for editing text properties on selected items.
class TextFormatBar extends StatelessWidget {
  const TextFormatBar({
    super.key,
    required this.selectedItem,
    required this.onDataChanged,
  });

  final InspirationItemModel selectedItem;
  final void Function(Map<String, dynamic> data) onDataChanged;

  /// Text color key differs by item type.
  String get _colorKey => selectedItem.type == 'text' ? 'color' : 'textColor';

  String get _currentColor =>
      selectedItem.data[_colorKey] as String? ??
      (selectedItem.type == 'text' ? '#FFFFFF' : '#000000');

  double get _currentFontSize =>
      (selectedItem.data['fontSize'] as num?)?.toDouble() ??
      (selectedItem.type == 'text' ? 18.0 : 14.0);

  bool get _isBold => selectedItem.data['fontWeight'] == 'bold';
  bool get _isItalic => selectedItem.data['fontStyle'] == 'italic';

  String get _currentAlign =>
      selectedItem.data['textAlign'] as String? ?? 'left';

  void _setColor(String hex) {
    onDataChanged({...selectedItem.data, _colorKey: hex});
  }

  void _setFontSize(double size) {
    onDataChanged({
      ...selectedItem.data,
      'fontSize': size.clamp(10.0, 48.0),
    });
  }

  void _toggleBold() {
    onDataChanged({
      ...selectedItem.data,
      'fontWeight': _isBold ? 'normal' : 'bold',
    });
  }

  void _toggleItalic() {
    onDataChanged({
      ...selectedItem.data,
      'fontStyle': _isItalic ? 'normal' : 'italic',
    });
  }

  void _setAlign(String align) {
    onDataChanged({...selectedItem.data, 'textAlign': align});
  }

  static Color _hexToColor(String hex) {
    final clean = hex.replaceFirst('#', '');
    if (clean.length == 6) {
      return Color(0xFF000000 | int.parse(clean, radix: 16));
    }
    return const Color(0xFFFFFFFF);
  }

  static String _colorName(String hex) => switch (hex) {
        '#FFFFFF' => 'White',
        '#000000' => 'Black',
        '#FF6B6B' => 'Red',
        '#6C63FF' => 'Violet',
        '#00C853' => 'Green',
        '#FFEB3B' => 'Yellow',
        _ => hex,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;
    final primary = Theme.of(context).colorScheme.primary;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.all(AppRadius.md),
        border: Border.all(color: borderColor),
        boxShadow: AppShadows.md,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text color dots
          ...toolbarColors.take(6).map((hex) {
            final color = _hexToColor(hex);
            final isSelected = _currentColor == hex;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Tooltip(
                message: _colorName(hex),
                child: GestureDetector(
                  onTap: () => _setColor(hex),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? primary : borderColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),

          _divider(mutedColor),

          // Font size controls
          Tooltip(
            message: 'Decrease font size',
            child: _iconButton(
              icon: LucideIcons.minus,
              onTap: () => _setFontSize(_currentFontSize - 2),
              color: mutedColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '${_currentFontSize.round()}',
              style: TextStyle(fontSize: 11, color: mutedColor),
            ),
          ),
          Tooltip(
            message: 'Increase font size',
            child: _iconButton(
              icon: LucideIcons.plus,
              onTap: () => _setFontSize(_currentFontSize + 2),
              color: mutedColor,
            ),
          ),

          _divider(mutedColor),

          // Bold toggle
          Tooltip(
            message: 'Bold',
            child: _toggleButton(
              label: 'B',
              isActive: _isBold,
              onTap: _toggleBold,
              primary: primary,
              mutedColor: mutedColor,
              bold: true,
            ),
          ),

          // Italic toggle
          Tooltip(
            message: 'Italic',
            child: _toggleButton(
              label: 'I',
              isActive: _isItalic,
              onTap: _toggleItalic,
              primary: primary,
              mutedColor: mutedColor,
              italic: true,
            ),
          ),

          _divider(mutedColor),

          // Alignment
          Tooltip(
            message: 'Align left',
            child: _alignButton(
              icon: LucideIcons.alignLeft,
              align: 'left',
              primary: primary,
              mutedColor: mutedColor,
            ),
          ),
          Tooltip(
            message: 'Align center',
            child: _alignButton(
              icon: LucideIcons.alignCenter,
              align: 'center',
              primary: primary,
              mutedColor: mutedColor,
            ),
          ),
          Tooltip(
            message: 'Align right',
            child: _alignButton(
              icon: LucideIcons.alignRight,
              align: 'right',
              primary: primary,
              mutedColor: mutedColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(Color color) => Container(
        width: 1,
        height: 20,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        color: color.withValues(alpha: 0.3),
      );

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 24,
        height: 24,
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }

  Widget _toggleButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required Color primary,
    required Color mutedColor,
    bool bold = false,
    bool italic = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color:
              isActive ? primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.all(AppRadius.sm),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
              color: isActive ? primary : mutedColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _alignButton({
    required IconData icon,
    required String align,
    required Color primary,
    required Color mutedColor,
  }) {
    final isActive = _currentAlign == align;
    return GestureDetector(
      onTap: () => _setAlign(align),
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color:
              isActive ? primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.all(AppRadius.sm),
        ),
        child: Icon(icon, size: 14, color: isActive ? primary : mutedColor),
      ),
    );
  }
}
