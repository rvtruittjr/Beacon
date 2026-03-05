import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../core/services/storage_service.dart';
import '../../models/inspiration_item_model.dart';
import '../../providers/tool_state_provider.dart';

class BoardItem extends ConsumerStatefulWidget {
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
  ConsumerState<BoardItem> createState() => _BoardItemState();
}

class _BoardItemState extends ConsumerState<BoardItem> {
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
    if (url == null || url.isEmpty) return;
    if (url.contains('supabase') && url.contains('brand-assets')) {
      final signed = await StorageService.toSignedUrl(url);
      if (mounted) setState(() => _signedUrl = signed);
    } else {
      setState(() => _signedUrl = url);
    }
  }

  bool get _showHandles {
    final selected = ref.watch(selectedItemProvider);
    return _hovered || selected == widget.item.id;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

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
            border: _showHandles
                ? Border.all(color: primary, width: 2)
                : null,
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

              // Delete button
              if (_showHandles)
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

              // Resize handle (bigger hit area: 36px)
              if (_showHandles)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (details) {
                      widget.onResized(details.delta.dx, details.delta.dy);
                    },
                    onPanEnd: (_) => widget.onResizeEnd(),
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.9),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                            ),
                          ),
                          child: const Icon(
                            Icons.drag_handle,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
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
