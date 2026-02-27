import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

/// Displays an image from a URL using a native HTML <img> element.
///
/// This bypasses Flutter web CanvasKit's image loading entirely, avoiding
/// CORS issues that break [Image.network] and [CachedNetworkImage].
/// The browser loads the image natively — no crossOrigin/fetch required.
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
  late final String _viewType;
  bool _hasError = false;
  bool _registered = false;

  @override
  void initState() {
    super.initState();
    _viewType = 'storage-img-${widget.url.hashCode}-${identityHashCode(this)}';
    _register();
  }

  void _register() {
    if (_registered) return;
    _registered = true;

    final fitCss = switch (widget.fit) {
      BoxFit.cover => 'cover',
      BoxFit.fill => 'fill',
      BoxFit.none => 'none',
      BoxFit.scaleDown => 'scale-down',
      _ => 'contain',
    };

    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        final img = html.ImageElement()
          ..src = widget.url
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = fitCss
          ..style.display = 'block';

        img.onError.listen((_) {
          if (mounted) setState(() => _hasError = true);
        });

        return img;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url.isEmpty || _hasError) {
      return widget.errorBuilder?.call(context) ??
          const Icon(Icons.image_outlined, size: 32);
    }

    return HtmlElementView(viewType: _viewType);
  }
}
