import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Downloads and registers custom font files at runtime so they can be
/// referenced by family name in [TextStyle].
class CustomFontLoader {
  CustomFontLoader._();

  static final Set<String> _loaded = {};
  static final Map<String, Future<void>> _pending = {};

  /// Returns true if [family] has already been loaded.
  static bool isLoaded(String family) => _loaded.contains(family);

  /// Downloads the font from [url] and registers it under [family].
  /// Subsequent calls with the same [family] are no-ops.
  static Future<void> load(String family, String url) async {
    if (_loaded.contains(family)) return;

    // Deduplicate concurrent loads for the same family.
    if (_pending.containsKey(family)) {
      return _pending[family];
    }

    _pending[family] = _doLoad(family, url);
    try {
      await _pending[family];
    } finally {
      _pending.remove(family);
    }
  }

  static Future<void> _doLoad(String family, String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return;

      final loader = FontLoader(family);
      loader.addFont(
        Future.value(
          ByteData.view(response.bodyBytes.buffer),
        ),
      );
      await loader.load();
      _loaded.add(family);
    } catch (_) {
      // Silently fail — the font will render in the fallback typeface.
    }
  }
}
