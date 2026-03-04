import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:archive/archive.dart';
import 'package:flutter/rendering.dart';

import '../../brand_snapshot/providers/snapshot_provider.dart';
import '../../brand_snapshot/services/pdf_export_service.dart';

class AssetPackService {
  /// Generate a ZIP archive containing all brand assets.
  static Future<Uint8List> generate(SnapshotData data) async {
    final archive = Archive();

    // 1. Brand info JSON
    final brandInfo = _buildBrandInfoJson(data);
    final jsonBytes = utf8.encode(const JsonEncoder.withIndent('  ').convert(brandInfo));
    archive.addFile(ArchiveFile(
      'brand-info.json',
      jsonBytes.length,
      jsonBytes,
    ));

    // 2. Logos
    for (int i = 0; i < data.logos.length; i++) {
      final url = data.logos[i]['file_url'] as String?;
      if (url == null || url.isEmpty) continue;

      final label = data.logos[i]['label'] as String? ?? 'logo_$i';
      final ext = _extensionFromUrl(url);

      try {
        final bytes = await PdfExportService.downloadImage(url);
        if (bytes != null && bytes.isNotEmpty) {
          final safeName = label.replaceAll(RegExp(r'[^\w\-.]'), '_');
          archive.addFile(ArchiveFile(
            'logos/$safeName$ext',
            bytes.length,
            bytes,
          ));
        }
      } catch (_) {
        // Skip failed downloads
      }
    }

    // 3. Uploaded fonts
    for (int i = 0; i < data.fonts.length; i++) {
      final url = data.fonts[i]['file_url'] as String?;
      if (url == null || url.isEmpty) continue;

      final family = data.fonts[i]['family'] as String? ?? 'font_$i';
      final ext = _extensionFromUrl(url);

      try {
        final bytes = await PdfExportService.downloadImage(url);
        if (bytes != null && bytes.isNotEmpty) {
          final safeName = family.replaceAll(RegExp(r'[^\w\-.]'), '_');
          archive.addFile(ArchiveFile(
            'fonts/$safeName$ext',
            bytes.length,
            bytes,
          ));
        }
      } catch (_) {
        // Skip failed downloads
      }
    }

    // 4. Color palette PNG
    if (data.colors.isNotEmpty) {
      try {
        final paletteBytes = await _renderColorPalette(data.colors);
        if (paletteBytes != null) {
          archive.addFile(ArchiveFile(
            'color-palette.png',
            paletteBytes.length,
            paletteBytes,
          ));
        }
      } catch (_) {
        // Skip if rendering fails
      }
    }

    // 5. Brand guidelines PDF
    try {
      final pdfBytes = await PdfExportService.generate(data);
      archive.addFile(ArchiveFile(
        'brand-guidelines.pdf',
        pdfBytes.length,
        pdfBytes,
      ));
    } catch (_) {
      // Skip if PDF generation fails
    }

    // Encode ZIP
    final zipData = ZipEncoder().encode(archive);
    return Uint8List.fromList(zipData!);
  }

  static Map<String, dynamic> _buildBrandInfoJson(SnapshotData data) {
    return {
      'brand': {
        'name': data.brand.name,
        'description': data.brand.description,
      },
      'colors': data.colors.map((c) => {
        'label': c['label'],
        'hex': c['hex'],
        'role': c['role'],
      }).toList(),
      'fonts': data.fonts.map((f) => {
        'family': f['family'],
        'label': f['label'],
        'source': f['source'],
      }).toList(),
      'voice': data.voice != null
          ? {
              'archetype': data.voice!['archetype'],
              'personality': data.voice!['personality'],
              'mission_statement': data.voice!['mission_statement'],
              'tone_formal': data.voice!['tone_formal'],
              'tone_serious': data.voice!['tone_serious'],
              'tone_bold': data.voice!['tone_bold'],
              'do_words': data.voice!['do_words'],
              'dont_words': data.voice!['dont_words'],
            }
          : null,
      'audience': data.audience != null
          ? {
              'persona_name': data.audience!['persona_name'],
              'persona_summary': data.audience!['persona_summary'],
              'age_range': data.audience!['age_range'],
              'interests': data.audience!['interests'],
              'pain_points': data.audience!['pain_points'],
              'goals': data.audience!['goals'],
            }
          : null,
      'content_pillars': data.pillars.map((p) => {
        'name': p['name'],
        'description': p['description'],
        'color': p['color'],
      }).toList(),
      'generated_by': 'Beacon',
    };
  }

  static String _extensionFromUrl(String url) {
    final path = url.split('?').first.toLowerCase();
    if (path.endsWith('.png')) return '.png';
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return '.jpg';
    if (path.endsWith('.svg')) return '.svg';
    if (path.endsWith('.webp')) return '.webp';
    if (path.endsWith('.otf')) return '.otf';
    if (path.endsWith('.ttf')) return '.ttf';
    if (path.endsWith('.woff')) return '.woff';
    if (path.endsWith('.woff2')) return '.woff2';
    return '';
  }

  /// Render color swatches to a PNG image using dart:ui Canvas.
  static Future<Uint8List?> _renderColorPalette(
    List<Map<String, dynamic>> colors,
  ) async {
    const swatchSize = 120.0;
    const padding = 16.0;
    const labelHeight = 40.0;
    final width = (colors.length * (swatchSize + padding) - padding + padding * 2).toInt();
    final height = (swatchSize + labelHeight + padding * 2).toInt();

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    // White background
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    );

    for (int i = 0; i < colors.length; i++) {
      final hex = colors[i]['hex'] as String? ?? '#888888';
      final label = colors[i]['label'] as String? ?? '';
      final color = _hexToColor(hex);

      final x = padding + i * (swatchSize + padding);

      // Draw circle swatch
      canvas.drawCircle(
        ui.Offset(x + swatchSize / 2, padding + swatchSize / 2),
        swatchSize / 2,
        ui.Paint()..color = color,
      );

      // Draw label text
      final labelParagraph = _buildParagraph(label, 11, const ui.Color(0xFF333333), swatchSize);
      canvas.drawParagraph(labelParagraph, ui.Offset(x, padding + swatchSize + 4));

      // Draw hex text
      final hexParagraph = _buildParagraph(hex, 10, const ui.Color(0xFF888888), swatchSize);
      canvas.drawParagraph(hexParagraph, ui.Offset(x, padding + swatchSize + 20));
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  static ui.Paragraph _buildParagraph(
    String text,
    double fontSize,
    ui.Color color,
    double maxWidth,
  ) {
    final builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(textAlign: ui.TextAlign.center, maxLines: 1),
    )
      ..pushStyle(ui.TextStyle(color: color, fontSize: fontSize))
      ..addText(text);
    final paragraph = builder.build();
    paragraph.layout(ui.ParagraphConstraints(width: maxWidth));
    return paragraph;
  }

  static ui.Color _hexToColor(String hex) {
    final clean = hex.replaceFirst('#', '');
    if (clean.length == 6 && RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(clean)) {
      return ui.Color(0xFF000000 | int.parse(clean, radix: 16));
    }
    return const ui.Color(0xFF888888);
  }
}
