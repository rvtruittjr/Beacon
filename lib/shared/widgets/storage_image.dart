import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/services/supabase_service.dart';

/// Loads an image from Supabase Storage by downloading the bytes directly.
///
/// This avoids CORS issues on Flutter web (CanvasKit) that occur with
/// [Image.network] and [CachedNetworkImage], and also handles SVG files.
class StorageImage extends StatefulWidget {
  const StorageImage({
    super.key,
    required this.url,
    this.bucket = 'brand-assets',
    this.fit = BoxFit.contain,
    this.errorBuilder,
  });

  /// The public or signed URL of the file in Supabase Storage.
  final String url;

  /// The storage bucket name.
  final String bucket;

  /// How the image should be inscribed into the space.
  final BoxFit fit;

  /// Builder shown when the image fails to load.
  final Widget Function(BuildContext context)? errorBuilder;

  @override
  State<StorageImage> createState() => _StorageImageState();
}

class _StorageImageState extends State<StorageImage> {
  late Future<_ImageData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(StorageImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _future = _load();
    }
  }

  Future<_ImageData> _load() async {
    final path = _extractPath(widget.url, widget.bucket);
    if (path == null) throw Exception('Invalid storage URL');

    final isSvg = path.toLowerCase().endsWith('.svg');
    final bytes = await SupabaseService.client.storage
        .from(widget.bucket)
        .download(path);

    return _ImageData(bytes: bytes, isSvg: isSvg);
  }

  /// Extract the storage path from a public or signed URL.
  static String? _extractPath(String url, String bucket) {
    // Public URL: .../object/public/<bucket>/<path>
    final publicMarker = '/object/public/$bucket/';
    var index = url.indexOf(publicMarker);
    if (index != -1) {
      return url.substring(index + publicMarker.length).split('?').first;
    }

    // Signed URL: .../object/sign/<bucket>/<path>?token=...
    final signMarker = '/object/sign/$bucket/';
    index = url.indexOf(signMarker);
    if (index != -1) {
      return url.substring(index + signMarker.length).split('?').first;
    }

    // Authenticated URL: .../object/authenticated/<bucket>/<path>
    final authMarker = '/object/authenticated/$bucket/';
    index = url.indexOf(authMarker);
    if (index != -1) {
      return url.substring(index + authMarker.length).split('?').first;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ImageData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return widget.errorBuilder?.call(context) ??
              const Icon(Icons.image_outlined, size: 32);
        }

        final data = snapshot.data!;

        if (data.isSvg) {
          return SvgPicture.memory(
            data.bytes,
            fit: widget.fit,
          );
        }

        return Image.memory(
          data.bytes,
          fit: widget.fit,
          errorBuilder: (ctx, _, __) =>
              widget.errorBuilder?.call(ctx) ??
              const Icon(Icons.image_outlined, size: 32),
        );
      },
    );
  }
}

class _ImageData {
  final Uint8List bytes;
  final bool isSvg;

  const _ImageData({required this.bytes, required this.isSvg});
}
