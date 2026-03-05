// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/config/design_tokens.dart';
import '../../../core/config/app_fonts.dart';
import '../../../shared/widgets/app_button.dart';
import '../../brand_snapshot/services/pdf_export_service.dart';
import '../models/platform_preset.dart';
import '../models/social_kit_edit_state.dart';
import '../providers/social_kit_edit_provider.dart';
import '../providers/social_kit_provider.dart';
import '../services/social_image_renderer.dart';
import '../services/social_kit_export_service.dart';
import 'widgets/color_picker_field.dart';

class SocialKitEditorScreen extends ConsumerStatefulWidget {
  const SocialKitEditorScreen({super.key, required this.presetKey});
  final String presetKey;

  @override
  ConsumerState<SocialKitEditorScreen> createState() =>
      _SocialKitEditorScreenState();
}

class _SocialKitEditorScreenState
    extends ConsumerState<SocialKitEditorScreen> {
  Uint8List? _previewBytes;
  bool _rendering = false;
  bool _downloading = false;
  Timer? _debounce;
  late TextEditingController _textController;

  PlatformPreset get _preset =>
      PlatformPreset.all.firstWhere((p) => p.key == widget.presetKey);

  SocialKitEditState get _edit =>
      ref.read(socialKitEditProvider)[widget.presetKey] ??
      const SocialKitEditState();

  void _updateEdit(SocialKitEditState edit) {
    ref.read(socialKitEditProvider.notifier).updateEdit(widget.presetKey, edit);
    _schedulePreview();
  }

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: _edit.textContent);
    _renderPreview();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textController.dispose();
    super.dispose();
  }

  void _schedulePreview() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _renderPreview);
  }

  Future<void> _renderPreview() async {
    if (_rendering) return;
    setState(() => _rendering = true);

    final data = ref.read(socialKitDataProvider).valueOrNull;
    if (data == null) {
      setState(() => _rendering = false);
      return;
    }

    final edit = _edit;
    final bgHex =
        edit.bgColorHex.isNotEmpty ? edit.bgColorHex : data.primaryColorHex;
    final bgColor = _hexToColor(bgHex);
    final textColor =
        edit.textColorHex.isNotEmpty ? _hexToColor(edit.textColorHex) : null;

    Uint8List? logoBytes;
    if (data.logoUrl != null && data.logoUrl!.isNotEmpty) {
      try {
        logoBytes = await PdfExportService.downloadImage(data.logoUrl!);
      } catch (_) {}
    }

    // Render at half resolution for preview
    final scale = 0.5;
    final pw = (_preset.width * scale).toInt().clamp(1, 1280);
    final ph = (_preset.height * scale).toInt().clamp(1, 1280);

    final bytes = await SocialImageRenderer.render(
      width: pw,
      height: ph,
      backgroundColor: bgColor,
      logoBytes: logoBytes,
      brandName: data.brandName,
      logoOffsetX: edit.logoOffsetX,
      logoOffsetY: edit.logoOffsetY,
      logoScale: edit.logoScale,
      textOverride: edit.textContent.isNotEmpty ? edit.textContent : null,
      fontSizeMultiplier: edit.fontSizeMultiplier,
      textColorOverride: textColor,
    );

    if (mounted) {
      setState(() {
        _previewBytes = bytes;
        _rendering = false;
      });
    }
  }

  Future<void> _download() async {
    setState(() => _downloading = true);
    try {
      final data = ref.read(socialKitDataProvider).valueOrNull;
      if (data == null) return;

      final bytes = await SocialKitExportService.generateSingle(
        preset: _preset,
        brandName: data.brandName,
        primaryColorHex: data.primaryColorHex,
        logoUrl: data.logoUrl,
        edit: _edit,
      );
      if (bytes == null) return;

      final blob = html.Blob([bytes], 'image/png');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', _preset.fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  void _reset() {
    ref.read(socialKitEditProvider.notifier).resetEdit(widget.presetKey);
    _textController.text = '';
    _schedulePreview();
  }

  static ui.Color _hexToColor(String hex) {
    final clean = hex.replaceFirst('#', '');
    if (clean.length == 6 && RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(clean)) {
      return ui.Color(0xFF000000 | int.parse(clean, radix: 16));
    }
    return const ui.Color(0xFF6C63FF);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final isWide = MediaQuery.sizeOf(context).width > 900;

    final edit = ref.watch(socialKitEditProvider)[widget.presetKey] ??
        const SocialKitEditState();

    final preview = _buildPreview(isDark, mutedColor);
    final controls = _buildControls(edit, textColor, mutedColor, surfaceColor, isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.go('/app/social-kit'),
                child: Icon(LucideIcons.arrowLeft, size: 20, color: textColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '${_preset.platform} ${_preset.variant}',
                style: AppFonts.clashDisplay(fontSize: 24, color: textColor),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _preset.displaySize,
                style: AppFonts.inter(fontSize: 13, color: mutedColor),
              ),
              const Spacer(),
              if (!edit.isDefault)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: AppButton(
                    label: 'Reset',
                    icon: LucideIcons.rotateCcw,
                    variant: AppButtonVariant.secondary,
                    onPressed: _reset,
                  ),
                ),
              AppButton(
                label: 'Download',
                icon: Icons.download,
                isLoading: _downloading,
                onPressed: _downloading ? null : _download,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Content
        Expanded(
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: preview),
                    Expanded(flex: 2, child: controls),
                  ],
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 300,
                        child: preview,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      controls,
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPreview(bool isDark, Color mutedColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: AspectRatio(
          aspectRatio: _preset.width / _preset.height,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(AppRadius.lg),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              boxShadow: AppShadows.md,
            ),
            clipBehavior: Clip.antiAlias,
            child: _previewBytes != null
                ? Image.memory(
                    _previewBytes!,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  )
                : Container(
                    color: isDark
                        ? AppColors.surfaceMidDark
                        : AppColors.surfaceMidLight,
                    child: Center(
                      child: _rendering
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: mutedColor,
                              ),
                            )
                          : Icon(_preset.icon, size: 40, color: mutedColor),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls(
    SocialKitEditState edit,
    Color textColor,
    Color mutedColor,
    Color surfaceColor,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.x2l,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.all(AppRadius.lg),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customize',
              style: AppFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Text content
            Text(
              'Display Text',
              style: AppFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _textController,
              style: AppFonts.inter(fontSize: 13, color: textColor),
              decoration: const InputDecoration(
                hintText: 'Brand name (leave empty for default)',
                isDense: true,
              ),
              onChanged: (val) =>
                  _updateEdit(edit.copyWith(textContent: val)),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Font size
            _SliderField(
              label: 'Font Size',
              value: edit.fontSizeMultiplier,
              min: 0.3,
              max: 3.0,
              displayValue: '${(edit.fontSizeMultiplier * 100).round()}%',
              onChanged: (v) =>
                  _updateEdit(edit.copyWith(fontSizeMultiplier: v)),
              textColor: textColor,
              mutedColor: mutedColor,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Logo scale
            _SliderField(
              label: 'Logo Scale',
              value: edit.logoScale,
              min: 0.1,
              max: 2.5,
              displayValue: '${(edit.logoScale * 100).round()}%',
              onChanged: (v) =>
                  _updateEdit(edit.copyWith(logoScale: v)),
              textColor: textColor,
              mutedColor: mutedColor,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Logo X offset
            _SliderField(
              label: 'Logo Horizontal',
              value: edit.logoOffsetX,
              min: -0.4,
              max: 0.4,
              displayValue:
                  '${(edit.logoOffsetX * 100).round().abs()}% ${edit.logoOffsetX >= 0 ? 'right' : 'left'}',
              onChanged: (v) =>
                  _updateEdit(edit.copyWith(logoOffsetX: v)),
              textColor: textColor,
              mutedColor: mutedColor,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Logo Y offset
            _SliderField(
              label: 'Logo Vertical',
              value: edit.logoOffsetY,
              min: -0.4,
              max: 0.4,
              displayValue:
                  '${(edit.logoOffsetY * 100).round().abs()}% ${edit.logoOffsetY >= 0 ? 'down' : 'up'}',
              onChanged: (v) =>
                  _updateEdit(edit.copyWith(logoOffsetY: v)),
              textColor: textColor,
              mutedColor: mutedColor,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Background color
            ColorPickerField(
              label: 'Background Color',
              hex: edit.bgColorHex.isNotEmpty
                  ? edit.bgColorHex
                  : ref.read(socialKitDataProvider).valueOrNull?.primaryColorHex ?? '#6C63FF',
              onChanged: (hex) =>
                  _updateEdit(edit.copyWith(bgColorHex: hex)),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Text color
            ColorPickerField(
              label: 'Text Color',
              hex: edit.textColorHex,
              onChanged: (hex) =>
                  _updateEdit(edit.copyWith(textColorHex: hex)),
              showAuto: true,
              isAuto: edit.textColorHex.isEmpty,
              onAutoToggled: () {
                if (edit.textColorHex.isNotEmpty) {
                  _updateEdit(edit.copyWith(textColorHex: ''));
                } else {
                  _updateEdit(edit.copyWith(textColorHex: '#FFFFFF'));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderField extends StatelessWidget {
  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.displayValue,
    required this.onChanged,
    required this.textColor,
    required this.mutedColor,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String displayValue;
  final ValueChanged<double> onChanged;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const Spacer(),
            Text(
              displayValue,
              style: AppFonts.inter(fontSize: 11, color: mutedColor),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveTrackColor: mutedColor.withValues(alpha: 0.2),
            thumbColor: Theme.of(context).colorScheme.primary,
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
