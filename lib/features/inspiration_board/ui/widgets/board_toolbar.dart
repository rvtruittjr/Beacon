import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../models/board_item_type.dart';
import '../../providers/tool_state_provider.dart';

class BoardToolbar extends ConsumerWidget {
  const BoardToolbar({super.key});

  static String _toolLabel(ToolMode mode) => switch (mode) {
        ToolMode.select => '',
        ToolMode.pen => 'Draw Mode',
        ToolMode.line => 'Line Mode',
        ToolMode.shape => 'Shape Mode',
        ToolMode.text => 'Text Mode',
        ToolMode.stickyNote => 'Note Mode',
        ToolMode.connector => 'Connect Mode',
        ToolMode.eraser => 'Erase Mode',
      };

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
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTool = ref.watch(activeToolProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    final label = _toolLabel(activeTool);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mode label pill (shown when not in select mode)
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.all(AppRadius.md),
              ),
              child: Text(
                label,
                style: AppFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),

        // Main tool buttons
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.all(AppRadius.lg),
            border: Border.all(color: borderColor),
            boxShadow: AppShadows.lg,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ToolButton(
                icon: LucideIcons.mousePointer2,
                label: 'Select',
                isActive: activeTool == ToolMode.select,
                onTap: () => ref.read(activeToolProvider.notifier).state =
                    ToolMode.select,
                textColor: textColor,
                mutedColor: mutedColor,
              ),
              _ToolButton(
                icon: LucideIcons.pencil,
                label: 'Draw',
                isActive: activeTool == ToolMode.pen,
                onTap: () => ref.read(activeToolProvider.notifier).state =
                    ToolMode.pen,
                textColor: textColor,
                mutedColor: mutedColor,
              ),
              _ToolButton(
                icon: LucideIcons.minus,
                label: 'Line',
                isActive: activeTool == ToolMode.line,
                onTap: () => ref.read(activeToolProvider.notifier).state =
                    ToolMode.line,
                textColor: textColor,
                mutedColor: mutedColor,
              ),
              _ToolButton(
                icon: LucideIcons.square,
                label: 'Shape',
                isActive: activeTool == ToolMode.shape,
                onTap: () => ref.read(activeToolProvider.notifier).state =
                    ToolMode.shape,
                textColor: textColor,
                mutedColor: mutedColor,
              ),
              _ToolButton(
                icon: LucideIcons.type,
                label: 'Text',
                isActive: activeTool == ToolMode.text,
                onTap: () => ref.read(activeToolProvider.notifier).state =
                    ToolMode.text,
                textColor: textColor,
                mutedColor: mutedColor,
              ),
              _ToolButton(
                icon: LucideIcons.stickyNote,
                label: 'Note',
                isActive: activeTool == ToolMode.stickyNote,
                onTap: () => ref.read(activeToolProvider.notifier).state =
                    ToolMode.stickyNote,
                textColor: textColor,
                mutedColor: mutedColor,
              ),
              _ToolButton(
                icon: LucideIcons.link,
                label: 'Connect',
                isActive: activeTool == ToolMode.connector,
                onTap: () {
                  ref.read(activeToolProvider.notifier).state =
                      ToolMode.connector;
                  ref.read(connectorSourceProvider.notifier).state = null;
                },
                textColor: textColor,
                mutedColor: mutedColor,
              ),
              _ToolButton(
                icon: LucideIcons.eraser,
                label: 'Erase',
                isActive: activeTool == ToolMode.eraser,
                onTap: () => ref.read(activeToolProvider.notifier).state =
                    ToolMode.eraser,
                textColor: textColor,
                mutedColor: mutedColor,
              ),
            ],
          ),
        ),
        // Sub-options bar
        if (activeTool == ToolMode.pen ||
            activeTool == ToolMode.shape ||
            activeTool == ToolMode.line ||
            activeTool == ToolMode.connector)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: _SubOptionsBar(
              activeTool: activeTool,
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              mutedColor: mutedColor,
            ),
          ),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.textColor,
    required this.mutedColor,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.all(AppRadius.md),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? primary.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.all(AppRadius.md),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isActive ? primary : mutedColor,
          ),
        ),
      ),
    );
  }
}

class _SubOptionsBar extends ConsumerWidget {
  const _SubOptionsBar({
    required this.activeTool,
    required this.surfaceColor,
    required this.borderColor,
    required this.mutedColor,
  });

  final ToolMode activeTool;
  final Color surfaceColor;
  final Color borderColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectorSource = ref.watch(connectorSourceProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
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
              // Color dots with tooltips
              ...toolbarColors.take(6).map((hex) {
                final color = _hexToColor(hex);
                final isSelected = switch (activeTool) {
                  ToolMode.pen => ref.watch(penColorProvider) == hex,
                  ToolMode.line => ref.watch(lineColorProvider) == hex,
                  ToolMode.connector => ref.watch(connectorColorProvider) == hex,
                  _ => ref.watch(shapeFillColorProvider) == hex,
                };
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Tooltip(
                    message: BoardToolbar._colorName(hex),
                    child: GestureDetector(
                      onTap: () {
                        if (activeTool == ToolMode.pen) {
                          ref.read(penColorProvider.notifier).state = hex;
                        } else if (activeTool == ToolMode.line) {
                          ref.read(lineColorProvider.notifier).state = hex;
                        } else if (activeTool == ToolMode.connector) {
                          ref.read(connectorColorProvider.notifier).state = hex;
                        } else {
                          ref.read(shapeFillColorProvider.notifier).state = hex;
                        }
                      },
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : borderColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              if (activeTool == ToolMode.pen) ...[
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Width',
                  style: TextStyle(fontSize: 10, color: mutedColor),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 80,
                  child: Slider(
                    value: ref.watch(penStrokeWidthProvider),
                    min: 1,
                    max: 12,
                    onChanged: (v) =>
                        ref.read(penStrokeWidthProvider.notifier).state = v,
                  ),
                ),
                Text(
                  '${ref.watch(penStrokeWidthProvider).round()}px',
                  style: TextStyle(fontSize: 10, color: mutedColor),
                ),
              ],
              if (activeTool == ToolMode.shape) ...[
                const SizedBox(width: AppSpacing.sm),
                Tooltip(
                  message: 'Rectangle',
                  child: _ShapeTypeButton(
                    icon: LucideIcons.square,
                    type: ShapeType.rectangle,
                    ref: ref,
                    mutedColor: mutedColor,
                  ),
                ),
                Tooltip(
                  message: 'Circle',
                  child: _ShapeTypeButton(
                    icon: LucideIcons.circle,
                    type: ShapeType.circle,
                    ref: ref,
                    mutedColor: mutedColor,
                  ),
                ),
                Tooltip(
                  message: 'Line',
                  child: _ShapeTypeButton(
                    icon: LucideIcons.minus,
                    type: ShapeType.line,
                    ref: ref,
                    mutedColor: mutedColor,
                  ),
                ),
                Tooltip(
                  message: 'Arrow',
                  child: _ShapeTypeButton(
                    icon: LucideIcons.arrowRight,
                    type: ShapeType.arrow,
                    ref: ref,
                    mutedColor: mutedColor,
                  ),
                ),
              ],
              if (activeTool == ToolMode.line) ...[
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Width',
                  style: TextStyle(fontSize: 10, color: mutedColor),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 80,
                  child: Slider(
                    value: ref.watch(lineStrokeWidthProvider),
                    min: 1,
                    max: 8,
                    onChanged: (v) =>
                        ref.read(lineStrokeWidthProvider.notifier).state = v,
                  ),
                ),
                Text(
                  '${ref.watch(lineStrokeWidthProvider).round()}px',
                  style: TextStyle(fontSize: 10, color: mutedColor),
                ),
                const SizedBox(width: AppSpacing.xs),
                Tooltip(
                  message: 'Toggle curved line',
                  child: _CurvedToggle(ref: ref, mutedColor: mutedColor),
                ),
              ],
            ],
          ),
        ),
        // Connector guidance text
        if (activeTool == ToolMode.connector)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withValues(alpha: 0.12),
                borderRadius: BorderRadius.all(AppRadius.md),
              ),
              child: Text(
                connectorSource == null
                    ? 'Tap the source item'
                    : 'Now tap the target item',
                style: AppFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2196F3),
                ),
              ),
            ),
          ),
      ],
    );
  }

  static Color _hexToColor(String hex) {
    final clean = hex.replaceFirst('#', '');
    if (clean.length == 6) {
      return Color(0xFF000000 | int.parse(clean, radix: 16));
    }
    return const Color(0xFFFFFFFF);
  }
}

class _ShapeTypeButton extends StatelessWidget {
  const _ShapeTypeButton({
    required this.icon,
    required this.type,
    required this.ref,
    required this.mutedColor,
  });

  final IconData icon;
  final ShapeType type;
  final WidgetRef ref;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final isActive = ref.watch(shapeTypeProvider) == type;
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => ref.read(shapeTypeProvider.notifier).state = type,
      child: Container(
        width: 30,
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: isActive ? primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.all(AppRadius.sm),
        ),
        child: Icon(icon, size: 16, color: isActive ? primary : mutedColor),
      ),
    );
  }
}

class _CurvedToggle extends StatelessWidget {
  const _CurvedToggle({required this.ref, required this.mutedColor});

  final WidgetRef ref;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final isCurved = ref.watch(lineCurvedProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () =>
          ref.read(lineCurvedProvider.notifier).state = !isCurved,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isCurved ? primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.all(AppRadius.sm),
          border: Border.all(
            color: isCurved ? primary : mutedColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.spline,
              size: 14,
              color: isCurved ? primary : mutedColor,
            ),
            const SizedBox(width: 4),
            Text(
              'Curve',
              style: TextStyle(
                fontSize: 11,
                color: isCurved ? primary : mutedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
