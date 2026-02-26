import 'package:flutter/material.dart';

import '../../core/config/design_tokens.dart';

enum AppButtonVariant { primary, secondary, ghost, destructive, icon }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  final String? label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isHovered = false;

  bool get _isDisabled => widget.onPressed == null || widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.variant == AppButtonVariant.icon) {
      return _buildIconButton(isDark);
    }

    final (bgColor, fgColor, borderSide) = _resolveColors(isDark);
    final effectiveBg =
        _isHovered && !_isDisabled ? _darken(bgColor, 0.1) : bgColor;

    final child = widget.isLoading
        ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: fgColor,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: fgColor),
                if (widget.label != null) const SizedBox(width: 8),
              ],
              if (widget.label != null)
                Text(
                  widget.label!,
                  style: TextStyle(
                    color: fgColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
            ],
          );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedOpacity(
        opacity: _isDisabled ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: SizedBox(
          width: widget.isFullWidth ? double.infinity : null,
          child: Material(
            color: effectiveBg,
            borderRadius: BorderRadius.all(AppRadius.full),
            child: InkWell(
              onTap: _isDisabled ? null : widget.onPressed,
              borderRadius: BorderRadius.all(AppRadius.full),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(AppRadius.full),
                  border: borderSide != null
                      ? Border.all(
                          color: borderSide.color,
                          width: borderSide.width,
                        )
                      : null,
                ),
                child: Center(
                  widthFactor: widget.isFullWidth ? null : 1.0,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(bool isDark) {
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final fgColor = _isHovered ? AppColors.blockLime : mutedColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedOpacity(
        opacity: _isDisabled ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: IconButton(
          onPressed: _isDisabled ? null : widget.onPressed,
          icon: widget.isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: fgColor,
                  ),
                )
              : Icon(widget.icon, size: 20, color: fgColor),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 40),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  (Color bg, Color fg, BorderSide? border) _resolveColors(bool isDark) {
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return switch (widget.variant) {
      AppButtonVariant.primary => (
          AppColors.blockLime,
          AppColors.textOnLime,
          null,
        ),
      AppButtonVariant.secondary => (
          Colors.transparent,
          textColor,
          BorderSide(color: borderColor, width: 2),
        ),
      AppButtonVariant.ghost => (
          Colors.transparent,
          _isHovered ? textColor : mutedColor,
          null,
        ),
      AppButtonVariant.destructive => (
          AppColors.blockCoral,
          AppColors.textOnCoral,
          null,
        ),
      AppButtonVariant.icon => (Colors.transparent, mutedColor, null),
    };
  }

  Color _darken(Color color, double amount) {
    if (color == Colors.transparent) return color;
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}
