import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide StorageException;

import '../errors/app_exception.dart';
import '../errors/error_handler.dart';
import 'supabase_service.dart';

class StorageService {
  StorageService._();

  static SupabaseStorageClient get _storage => SupabaseService.client.storage;

  static Future<String> uploadAsset(
    String userId,
    String brandId,
    String assetId,
    PlatformFile file,
  ) async {
    final path = '$userId/$brandId/assets/$assetId/${file.name}';
    return _upload('brand-assets', path, file);
  }

  static Future<String> uploadArchiveThumbnail(
    String userId,
    String brandId,
    String contentId,
    PlatformFile file,
  ) async {
    final path = '$userId/$brandId/archive/$contentId/thumbnail.jpg';
    return _upload('archive-media', path, file);
  }

  static Future<String> uploadArchiveVideo(
    String userId,
    String brandId,
    String contentId,
    PlatformFile file,
  ) async {
    final ext = file.extension ?? 'mp4';
    final path = '$userId/$brandId/archive/$contentId/video.$ext';
    return _upload('archive-media', path, file);
  }

  static Future<String> uploadFont(
    String userId,
    String brandId,
    PlatformFile file,
  ) async {
    final path = '$userId/$brandId/fonts/${file.name}';
    return _upload('brand-assets', path, file);
  }

  static Future<void> deleteFile(String bucket, String path) async {
    try {
      await _storage.from(bucket).remove([path]);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  static Future<String> getSignedUrl(
    String bucket,
    String path, {
    Duration expiry = const Duration(hours: 1),
  }) async {
    try {
      return await _storage.from(bucket).createSignedUrl(
            path,
            expiry.inSeconds,
          );
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  /// Convert a public URL back to a signed URL.
  /// Public URLs have the format: .../object/public/<bucket>/<path>
  /// Returns the original URL if it can't be parsed.
  static Future<String> toSignedUrl(String publicUrl, {
    String bucket = 'brand-assets',
    Duration expiry = const Duration(hours: 1),
  }) async {
    final marker = '/object/public/$bucket/';
    final index = publicUrl.indexOf(marker);
    if (index == -1) return publicUrl;
    final path = publicUrl.substring(index + marker.length).split('?').first;
    try {
      return await _storage.from(bucket).createSignedUrl(path, expiry.inSeconds);
    } catch (_) {
      return publicUrl; // fallback to public URL
    }
  }

  /// Batch-convert multiple public URLs to signed URLs.
  static Future<List<String>> toSignedUrls(List<String> publicUrls, {
    String bucket = 'brand-assets',
    Duration expiry = const Duration(hours: 1),
  }) async {
    final marker = '/object/public/$bucket/';
    final paths = <String>[];
    final indexMap = <int, int>{}; // maps paths index → publicUrls index

    for (int i = 0; i < publicUrls.length; i++) {
      final url = publicUrls[i];
      final idx = url.indexOf(marker);
      if (idx != -1) {
        indexMap[paths.length] = i;
        paths.add(url.substring(idx + marker.length).split('?').first);
      }
    }

    if (paths.isEmpty) return publicUrls;

    try {
      final signed = await _storage.from(bucket).createSignedUrls(paths, expiry.inSeconds);
      final result = List<String>.from(publicUrls);
      for (int i = 0; i < signed.length; i++) {
        final origIdx = indexMap[i];
        final signedUrl = signed[i].signedUrl;
        if (origIdx != null && signedUrl.isNotEmpty) {
          result[origIdx] = signedUrl;
        }
      }
      return result;
    } catch (_) {
      return publicUrls;
    }
  }

  static Future<String> _upload(
    String bucket,
    String path,
    PlatformFile file,
  ) async {
    try {
      final bytes = file.bytes;
      if (bytes == null) {
        throw const StorageException('File bytes are null. Cannot upload.');
      }

      await _storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: _mimeType(file),
              upsert: true,
            ),
          );

      return _storage.from(bucket).getPublicUrl(path);
    } catch (e, stack) {
      if (e is AppException) rethrow;
      ErrorHandler.throwHandled(e, stack);
    }
  }

  static String _mimeType(PlatformFile file) {
    final ext = file.extension?.toLowerCase();
    return switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'svg' => 'image/svg+xml',
      'mp4' => 'video/mp4',
      'mov' => 'video/quicktime',
      'pdf' => 'application/pdf',
      'otf' => 'font/otf',
      'ttf' => 'font/ttf',
      'woff' => 'font/woff',
      'woff2' => 'font/woff2',
      _ => 'application/octet-stream',
    };
  }
}
