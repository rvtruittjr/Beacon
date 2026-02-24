import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
