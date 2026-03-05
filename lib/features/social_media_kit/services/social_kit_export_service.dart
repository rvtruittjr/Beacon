import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:archive/archive.dart';

import '../models/platform_preset.dart';
import '../models/social_kit_edit_state.dart';
import '../../brand_snapshot/services/pdf_export_service.dart';
import 'social_image_renderer.dart';

class SocialKitExportService {
  SocialKitExportService._();

  /// Generate a ZIP of all social media images for the given brand.
  static Future<Uint8List> generateZip({
    required String brandName,
    required String primaryColorHex,
    String? logoUrl,
    Map<String, SocialKitEditState> edits = const {},
  }) async {
    final archive = Archive();
    final bgColor = _hexToColor(primaryColorHex);

    // Download logo once
    Uint8List? logoBytes;
    if (logoUrl != null && logoUrl.isNotEmpty) {
      try {
        logoBytes = await PdfExportService.downloadImage(logoUrl);
      } catch (_) {}
    }

    for (final preset in PlatformPreset.all) {
      final edit = edits[preset.key];
      final effectiveBg = (edit != null && edit.bgColorHex.isNotEmpty)
          ? _hexToColor(edit.bgColorHex)
          : bgColor;
      final effectiveTextColor = (edit != null && edit.textColorHex.isNotEmpty)
          ? _hexToColor(edit.textColorHex)
          : null;

      final pngBytes = await SocialImageRenderer.render(
        width: preset.width,
        height: preset.height,
        backgroundColor: effectiveBg,
        logoBytes: logoBytes,
        brandName: brandName,
        logoOffsetX: edit?.logoOffsetX ?? 0.0,
        logoOffsetY: edit?.logoOffsetY ?? 0.0,
        logoScale: edit?.logoScale ?? 1.0,
        textOverride: (edit != null && edit.textContent.isNotEmpty)
            ? edit.textContent
            : null,
        fontSizeMultiplier: edit?.fontSizeMultiplier ?? 1.0,
        textColorOverride: effectiveTextColor,
      );
      if (pngBytes != null) {
        archive.addFile(ArchiveFile(
          '${preset.platform}/${preset.fileName}',
          pngBytes.length,
          pngBytes,
        ));
      }
    }

    final zipData = ZipEncoder().encode(archive);
    return Uint8List.fromList(zipData!);
  }

  /// Generate a single image for one preset.
  static Future<Uint8List?> generateSingle({
    required PlatformPreset preset,
    required String brandName,
    required String primaryColorHex,
    String? logoUrl,
    SocialKitEditState? edit,
  }) async {
    final bgColor = (edit != null && edit.bgColorHex.isNotEmpty)
        ? _hexToColor(edit.bgColorHex)
        : _hexToColor(primaryColorHex);

    final textColor = (edit != null && edit.textColorHex.isNotEmpty)
        ? _hexToColor(edit.textColorHex)
        : null;

    Uint8List? logoBytes;
    if (logoUrl != null && logoUrl.isNotEmpty) {
      try {
        logoBytes = await PdfExportService.downloadImage(logoUrl);
      } catch (_) {}
    }

    return SocialImageRenderer.render(
      width: preset.width,
      height: preset.height,
      backgroundColor: bgColor,
      logoBytes: logoBytes,
      brandName: brandName,
      logoOffsetX: edit?.logoOffsetX ?? 0.0,
      logoOffsetY: edit?.logoOffsetY ?? 0.0,
      logoScale: edit?.logoScale ?? 1.0,
      textOverride:
          (edit != null && edit.textContent.isNotEmpty) ? edit.textContent : null,
      fontSizeMultiplier: edit?.fontSizeMultiplier ?? 1.0,
      textColorOverride: textColor,
    );
  }

  static ui.Color _hexToColor(String hex) {
    final clean = hex.replaceFirst('#', '');
    if (clean.length == 6 && RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(clean)) {
      return ui.Color(0xFF000000 | int.parse(clean, radix: 16));
    }
    return const ui.Color(0xFF6C63FF);
  }
}
