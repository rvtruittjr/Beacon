import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/services/supabase_service.dart';

/// Displays an image stored in Supabase Storage.
///
/// Downloads via an authenticated HTTP request directly to the Supabase
/// Storage REST API, completely bypassing both public URLs (which return 400
/// on private buckets) and the SDK's download() method (which can fail on web).
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

    // Build an authenticated request to the Supabase Storage REST API.
    // This bypasses public URLs (400 on private buckets) and the SDK's
    // download() method (unreliable on Flutter web).
    final token = SupabaseService.client.auth.currentSession?.accessToken;
    if (token == null) {
      if (mounted) setState(() { _hasError = true; _loading = false; });
      return;
    }

    // Encode each path segment individually to handle spaces/special chars
    final encodedPath =
        path.split('/').map(Uri.encodeComponent).join('/');
    final requestUrl = Uri.parse(
      '${AppConfig.supabaseUrl}/storage/v1/object/${widget.bucket}/$encodedPath',
    );

    try {
      final response = await http.get(requestUrl, headers: {
        'Authorization': 'Bearer $token',
        'apikey': AppConfig.supabaseAnonKey,
      });

      if (!mounted) return;

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        setState(() { _bytes = response.bodyBytes; _loading = false; });
      } else {
        setState(() { _hasError = true; _loading = false; });
      }
    } catch (_) {
      if (mounted) setState(() { _hasError = true; _loading = false; });
    }
  }

  /// Extract storage path from a public or signed Supabase Storage URL.
  String? _extractPath(String url) {
    // Public: .../object/public/<bucket>/<path>
    final publicMarker = '/object/public/${widget.bucket}/';
    var idx = url.indexOf(publicMarker);
    if (idx != -1) {
      final raw = url.substring(idx + publicMarker.length).split('?').first;
      return Uri.decodeFull(raw);
    }

    // Signed: .../object/sign/<bucket>/<path>?token=...
    final signMarker = '/object/sign/${widget.bucket}/';
    idx = url.indexOf(signMarker);
    if (idx != -1) {
      final raw = url.substring(idx + signMarker.length).split('?').first;
      return Uri.decodeFull(raw);
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
