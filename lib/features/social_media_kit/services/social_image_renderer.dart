import 'dart:typed_data';
import 'dart:ui' as ui;

/// Renders a branded social media image using dart:ui Canvas.
class SocialImageRenderer {
  SocialImageRenderer._();

  /// Render a PNG image with:
  /// - [backgroundColor] fill
  /// - [logoBytes] centered (optional)
  /// - [brandName] text below logo
  static Future<Uint8List?> render({
    required int width,
    required int height,
    required ui.Color backgroundColor,
    Uint8List? logoBytes,
    required String brandName,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final w = width.toDouble();
    final h = height.toDouble();

    // 1. Fill background
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, w, h),
      ui.Paint()..color = backgroundColor,
    );

    // Auto-contrast text color
    final luminance = _luminance(backgroundColor);
    final textColor =
        luminance > 0.5 ? const ui.Color(0xFF1A1A1A) : const ui.Color(0xFFFFFFFF);

    double logoBottom = h * 0.4;

    // 2. Draw centered logo
    if (logoBytes != null && logoBytes.isNotEmpty) {
      try {
        final maxLogoW = (w * 0.35).toInt();
        final maxLogoH = (h * 0.35).toInt();

        final codec = await ui.instantiateImageCodec(
          logoBytes,
          targetWidth: maxLogoW,
          targetHeight: maxLogoH,
        );
        final frame = await codec.getNextFrame();
        final image = frame.image;

        final imgW = image.width.toDouble();
        final imgH = image.height.toDouble();
        final dx = (w - imgW) / 2;
        final dy = (h - imgH) / 2 - h * 0.08;
        canvas.drawImage(image, ui.Offset(dx, dy), ui.Paint());
        logoBottom = dy + imgH + 16;
      } catch (_) {
        // Skip logo if decoding fails
      }
    }

    // 3. Draw brand name text below logo
    if (brandName.isNotEmpty) {
      final fontSize = (w * 0.05).clamp(14.0, 72.0);
      final paragraph = _buildParagraph(brandName, fontSize, textColor, w * 0.8);
      final textX = (w - w * 0.8) / 2;
      canvas.drawParagraph(paragraph, ui.Offset(textX, logoBottom));
    }

    // 4. Convert to PNG
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
      ui.ParagraphStyle(
        textAlign: ui.TextAlign.center,
        maxLines: 2,
      ),
    )
      ..pushStyle(ui.TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: ui.FontWeight.w700,
      ))
      ..addText(text);
    final paragraph = builder.build();
    paragraph.layout(ui.ParagraphConstraints(width: maxWidth));
    return paragraph;
  }

  static double _luminance(ui.Color color) {
    final r = color.red / 255.0;
    final g = color.green / 255.0;
    final b = color.blue / 255.0;
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }
}
