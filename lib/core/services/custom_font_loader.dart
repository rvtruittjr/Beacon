import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'supabase_service.dart';

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
      final bytes = await _downloadAuthenticated(url);
      if (bytes == null) return;

      final loader = FontLoader(family);
      loader.addFont(
        Future.value(ByteData.view(bytes.buffer)),
      );
      await loader.load();
      _loaded.add(family);
    } catch (_) {
      // Silently fail — the font will render in the fallback typeface.
    }
  }

  /// Download from Supabase Storage using authenticated HTTP request.
  /// Retries up to 3 times with delays to handle auth session timing.
  static Future<Uint8List?> _downloadAuthenticated(String url) async {
    const bucket = 'brand-assets';
    final path = _extractPath(url, bucket);
    if (path == null) return null;

    for (int attempt = 0; attempt < 3; attempt++) {
      final token = SupabaseService.client.auth.currentSession?.accessToken;
      if (token == null) {
        await Future.delayed(const Duration(milliseconds: 500));
        continue;
      }

      final requestUrl = Uri.parse(
        '${AppConfig.supabaseUrl}/storage/v1/object/$bucket/$path',
      );

      try {
        final response = await http.get(requestUrl, headers: {
          'Authorization': 'Bearer $token',
          'apikey': AppConfig.supabaseAnonKey,
        });

        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          return response.bodyBytes;
        }
      } catch (_) {
        // Network error — retry
      }

      if (attempt < 2) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    // Final fallback: try signed URL via SDK
    try {
      final signedUrl = await SupabaseService.client.storage
          .from(bucket)
          .createSignedUrl(path, 3600);
      final response = await http.get(Uri.parse(signedUrl));
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      }
    } catch (_) {}

    return null;
  }

  /// Extract the raw URL-encoded storage path from a Supabase Storage URL.
  static String? _extractPath(String url, String bucket) {
    final publicMarker = '/object/public/$bucket/';
    var idx = url.indexOf(publicMarker);
    if (idx != -1) {
      return url.substring(idx + publicMarker.length).split('?').first;
    }

    final signMarker = '/object/sign/$bucket/';
    idx = url.indexOf(signMarker);
    if (idx != -1) {
      return url.substring(idx + signMarker.length).split('?').first;
    }

    // Fallback: look for bucket name anywhere in URL
    final bucketMarker = '/$bucket/';
    idx = url.indexOf(bucketMarker);
    if (idx != -1) {
      return url.substring(idx + bucketMarker.length).split('?').first;
    }

    return null;
  }
}
