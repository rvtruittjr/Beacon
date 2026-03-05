import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/design_tokens.dart';
import '../../models/platform_preset.dart';
import '../../models/social_kit_edit_state.dart';
import '../../providers/social_kit_edit_provider.dart';
import '../../providers/social_kit_provider.dart';
import '../../services/social_image_renderer.dart';
import '../../../brand_snapshot/services/pdf_export_service.dart';

class PreviewThumbnail extends ConsumerStatefulWidget {
  const PreviewThumbnail({
    super.key,
    required this.preset,
  });

  final PlatformPreset preset;

  @override
  ConsumerState<PreviewThumbnail> createState() => _PreviewThumbnailState();
}

class _PreviewThumbnailState extends ConsumerState<PreviewThumbnail> {
  Uint8List? _imageBytes;
  bool _loading = true;
  String? _lastCacheKey;

  @override
  void initState() {
    super.initState();
    _generatePreview();
  }

  String _cacheKey(SocialKitData? data, SocialKitEditState edit) {
    return '${widget.preset.key}_${data?.brandName}_${data?.primaryColorHex}_${data?.logoUrl}'
        '_${edit.logoOffsetX}_${edit.logoOffsetY}_${edit.logoScale}'
        '_${edit.textContent}_${edit.fontSizeMultiplier}'
        '_${edit.bgColorHex}_${edit.textColorHex}';
  }

  Future<void> _generatePreview() async {
    final data = ref.read(socialKitDataProvider).valueOrNull;
    if (data == null) return;

    final edit = ref.read(socialKitEditProvider)[widget.preset.key] ??
        const SocialKitEditState();
    final key = _cacheKey(data, edit);
    if (key == _lastCacheKey) return;

    setState(() => _loading = true);

    try {
      final bgHex = edit.bgColorHex.isNotEmpty
          ? edit.bgColorHex
          : data.primaryColorHex;
      final bgColor = _hexToColor(bgHex);
      final textColor =
          edit.textColorHex.isNotEmpty ? _hexToColor(edit.textColorHex) : null;

      Uint8List? logoBytes;
      if (data.logoUrl != null && data.logoUrl!.isNotEmpty) {
        try {
          logoBytes = await PdfExportService.downloadImage(data.logoUrl!);
        } catch (_) {}
      }

      // Render at 1/4 resolution for performance
      final scale = 0.25;
      final thumbW = (widget.preset.width * scale).toInt().clamp(1, 640);
      final thumbH = (widget.preset.height * scale).toInt().clamp(1, 640);

      final bytes = await SocialImageRenderer.render(
        width: thumbW,
        height: thumbH,
        backgroundColor: bgColor,
        logoBytes: logoBytes,
        brandName: data.brandName,
        logoOffsetX: edit.logoOffsetX,
        logoOffsetY: edit.logoOffsetY,
        logoScale: edit.logoScale,
        textOverride:
            edit.textContent.isNotEmpty ? edit.textContent : null,
        fontSizeMultiplier: edit.fontSizeMultiplier,
        textColorOverride: textColor,
      );

      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _loading = false;
          _lastCacheKey = key;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _generatePreview();
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
    // Rebuild on edit state changes
    ref.listen(socialKitEditProvider, (_, __) => _generatePreview());
    ref.listen(socialKitDataProvider, (_, __) => _generatePreview());

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    if (_loading && _imageBytes == null) {
      return Container(
        color: isDark ? AppColors.surfaceMidDark : AppColors.surfaceMidLight,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: mutedColor,
            ),
          ),
        ),
      );
    }

    if (_imageBytes != null) {
      return Image.memory(
        _imageBytes!,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
    }

    return Container(
      color: isDark ? AppColors.surfaceMidDark : AppColors.surfaceMidLight,
      child: Center(
        child: Icon(widget.preset.icon, size: 32, color: mutedColor),
      ),
    );
  }
}
