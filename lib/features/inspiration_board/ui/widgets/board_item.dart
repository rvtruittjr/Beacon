import 'package:flutter/material.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../core/services/storage_service.dart';
import '../../models/inspiration_item_model.dart';

class BoardItem extends StatefulWidget {
  const BoardItem({
    super.key,
    required this.item,
    required this.onMoved,
    required this.onDragEnd,
    required this.onResized,
    required this.onResizeEnd,
    required this.onDelete,
  });

  final InspirationItemModel item;
  final void Function(double dx, double dy) onMoved;
  final VoidCallback onDragEnd;
  final void Function(double dw, double dh) onResized;
  final VoidCallback onResizeEnd;
  final VoidCallback onDelete;

  @override
  State<BoardItem> createState() => _BoardItemState();
}

class _BoardItemState extends State<BoardItem> {
  bool _hovered = false;
  String? _signedUrl;

  @override
  void initState() {
    super.initState();
    _resolveUrl();
  }

  @override
  void didUpdateWidget(BoardItem old) {
    super.didUpdateWidget(old);
    if (old.item.imageUrl != widget.item.imageUrl) _resolveUrl();
  }

  Future<void> _resolveUrl() async {
    final url = widget.item.imageUrl;
    // If it's a Supabase storage URL, get a signed URL
    if (url.contains('supabase') && url.contains('brand-assets')) {
      final signed = await StorageService.toSignedUrl(url);
      if (mounted) setState(() => _signedUrl = signed);
    } else {
      setState(() => _signedUrl = url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onPanUpdate: (details) {
          widget.onMoved(details.delta.dx, details.delta.dy);
        },
        onPanEnd: (_) => widget.onDragEnd(),
        child: Container(
          width: widget.item.width,
          height: widget.item.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(AppRadius.md),
            boxShadow: AppShadows.md,
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              if (_signedUrl != null)
                Image.network(
                  _signedUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                    ),
                  ),
                )
              else
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),

              // Caption overlay
              if (widget.item.caption != null &&
                  widget.item.caption!.isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: Text(
                      widget.item.caption!,
                      style: AppFonts.inter(fontSize: 12, color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

              // Delete button (on hover)
              if (_hovered)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: widget.onDelete,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              // Resize handle (bottom-right corner)
              if (_hovered)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      widget.onResized(details.delta.dx, details.delta.dy);
                    },
                    onPanEnd: (_) => widget.onResizeEnd(),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.8),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                        ),
                      ),
                      child: const Icon(
                        Icons.drag_handle,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
