import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/services/supabase_service.dart';

/// Displays an image stored in Supabase Storage.
///
/// Downloads via authenticated HTTP, with automatic retry and a signed-URL
/// fallback when the auth session isn't immediately available.
class StorageImage extends StatefulWidget {
  const StorageImage({
    super.key,
    required this.url,
    this.bucket = 'brand-assets',
    this.fit = BoxFit.contain,
    this.errorBuilder,
  });

  final String url;
  final String bucket;
  final BoxFit fit;
  final Widget Function(BuildContext context)? errorBuilder;

  @override
  State<StorageImage> createState() => _StorageImageState();
}

class _StorageImageState extends State<StorageImage> {
  Uint8List? _bytes;
  bool _loading = true;
  bool _hasError = false;
  bool _isSvg = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(StorageImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (widget.url.isEmpty) {
      if (mounted) setState(() { _hasError = true; _loading = false; });
      return;
    }

    setState(() { _loading = true; _hasError = false; _bytes = null; });

    _isSvg = widget.url.split('?').first.toLowerCase().endsWith('.svg');

    final path = _extractPath(widget.url);
    if (path == null) {
      if (mounted) setState(() { _hasError = true; _loading = false; });
      return;
    }

    // Attempt 1: authenticated HTTP request (with retry for token availability)
    final bytes = await _downloadAuthenticated(path);
    if (bytes != null) {
      if (mounted) setState(() { _bytes = bytes; _loading = false; });
      return;
    }

    // Attempt 2: signed URL via SDK (different auth flow, may succeed when
    // the direct approach fails due to CORS or timing issues)
    final signedBytes = await _downloadViaSigned(path);
    if (signedBytes != null) {
      if (mounted) setState(() { _bytes = signedBytes; _loading = false; });
      return;
    }

    if (mounted) setState(() { _hasError = true; _loading = false; });
  }

  /// Download bytes via an authenticated HTTP request to the Storage REST API.
  /// Retries up to 3 times with 500 ms delay to handle auth session timing.
  Future<Uint8List?> _downloadAuthenticated(String path) async {
    for (int attempt = 0; attempt < 3; attempt++) {
      final token = SupabaseService.client.auth.currentSession?.accessToken;
      if (token == null) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return null;
        continue;
      }

      final requestUrl = Uri.parse(
        '${AppConfig.supabaseUrl}/storage/v1/object/${widget.bucket}/$path',
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
        // Network error — try again
      }

      if (attempt < 2) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return null;
      }
    }
    return null;
  }

  /// Fallback: create a signed URL via the SDK and download from that.
  Future<Uint8List?> _downloadViaSigned(String path) async {
    try {
      final signedUrl = await SupabaseService.client.storage
          .from(widget.bucket)
          .createSignedUrl(path, 3600);

      final response = await http.get(Uri.parse(signedUrl));
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      }
    } catch (_) {
      // Signed URL approach also failed
    }
    return null;
  }

  /// Extract the storage path from a Supabase Storage URL.
  String? _extractPath(String url) {
    // Public: .../object/public/<bucket>/<path>
    final publicMarker = '/object/public/${widget.bucket}/';
    var idx = url.indexOf(publicMarker);
    if (idx != -1) {
      return url.substring(idx + publicMarker.length).split('?').first;
    }

    // Signed: .../object/sign/<bucket>/<path>?token=...
    final signMarker = '/object/sign/${widget.bucket}/';
    idx = url.indexOf(signMarker);
    if (idx != -1) {
      return url.substring(idx + signMarker.length).split('?').first;
    }

    // Authenticated: .../object/<bucket>/<path>
    final authMarker = '/object/${widget.bucket}/';
    idx = url.indexOf(authMarker);
    if (idx != -1) {
      // Make sure we didn't match /object/public/ or /object/sign/
      final before = url.substring(0, idx + '/object/'.length);
      if (!before.endsWith('/public/') && !before.endsWith('/sign/')) {
        return url.substring(idx + authMarker.length).split('?').first;
      }
    }

    // Last resort: look for bucket name anywhere in the URL
    final bucketMarker = '/${widget.bucket}/';
    idx = url.indexOf(bucketMarker);
    if (idx != -1) {
      return url.substring(idx + bucketMarker.length).split('?').first;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_hasError || _bytes == null) {
      return widget.errorBuilder?.call(context) ??
          const Icon(Icons.image_outlined, size: 32);
    }

    if (_isSvg) {
      return SvgPicture.memory(_bytes!, fit: widget.fit);
    }

    return Image.memory(_bytes!, fit: widget.fit);
  }
}
