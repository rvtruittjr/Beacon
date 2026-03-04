import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:archive/archive.dart';

import '../models/platform_preset.dart';
import '../../brand_snapshot/services/pdf_export_service.dart';
import 'social_image_renderer.dart';

class SocialKitExportService {
  SocialKitExportService._();

  /// Generate a ZIP of all social media images for the given brand.
  static Future<Uint8List> generateZip({
    required String brandName,
    required String primaryColorHex,
    String? logoUrl,
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
      final pngBytes = await SocialImageRenderer.render(
        width: preset.width,
        height: preset.height,
        backgroundColor: bgColor,
        logoBytes: logoBytes,
        brandName: brandName,
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
  }) async {
    final bgColor = _hexToColor(primaryColorHex);

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
