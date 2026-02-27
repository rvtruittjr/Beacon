import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../models/asset_model.dart';

class AssetCard extends StatefulWidget {
  const AssetCard({
    super.key,
    required this.asset,
    required this.onDelete,
    required this.onRename,
  });

  final AssetModel asset;
  final VoidCallback onDelete;
  final void Function(String newName) onRename;

  @override
  State<AssetCard> createState() => _AssetCardState();
}

class _AssetCardState extends State<AssetCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = theme.colorScheme.surface;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onSecondaryTapUp: (details) =>
            _showContextMenu(context, details.globalPosition),
        onLongPress: () {
          final box = context.findRenderObject() as RenderBox?;
          if (box == null) return;
          final pos = box.localToGlobal(Offset.zero) +
              Offset(box.size.width / 2, box.size.height / 2);
          _showContextMenu(context, pos);
        },
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.all(AppRadius.lg),
            boxShadow: isDark ? null : AppShadows.sm,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail (16:9)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildThumbnail(isDark, mutedColor),
                    // Hover overlay
                    if (_isHovered)
                      Container(
                        color: Colors.black.withValues(alpha: 0.4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.download_outlined,
                                  color: Colors.white, size: 20),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_vert,
                                  color: Colors.white, size: 20),
                              onPressed: () {
                                final box =
                                    context.findRenderObject() as RenderBox?;
                                if (box == null) return;
                                final pos = box.localToGlobal(Offset.zero) +
                                    Offset(box.size.width, 0);
                                _showContextMenu(context, pos);
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Body
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.asset.name,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (widget.asset.fileType != null)
                            AppBadge(label: widget.asset.fileType!),
                          if (widget.asset.fileSizeDisplay.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              widget.asset.fileSizeDisplay,
                              style: TextStyle(
                                color: mutedColor,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(bool isDark, Color mutedColor) {
    final asset = widget.asset;
    final bgColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    if (asset.isImage) {
      return CachedNetworkImage(
        imageUrl: asset.fileUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: bgColor,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: mutedColor,
              ),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          color: bgColor,
          child: Icon(Icons.broken_image_outlined,
              color: mutedColor, size: 32),
        ),
      );
    }

    if (asset.isVideo) {
      return Container(
        color: bgColor,
        child: Center(
          child: Icon(Icons.play_circle_outline,
              color: mutedColor, size: 40),
        ),
      );
    }

    if (asset.isFont) {
      return Container(
        color: bgColor,
        child: Center(
          child: Text(
            'Aa',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: mutedColor,
            ),
          ),
        ),
      );
    }

    // Document / other
    return Container(
      color: bgColor,
      child: Center(
        child: Icon(Icons.description_outlined,
            color: mutedColor, size: 36),
      ),
    );
  }

  void _showContextMenu(BuildContext context, Offset position) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: const [
        PopupMenuItem(value: 'download', child: Text('Download')),
        PopupMenuItem(value: 'rename', child: Text('Rename')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    ).then((value) {
      if (value == 'delete') widget.onDelete();
      if (value == 'rename') _showRenameDialog(context);
    });
  }

  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: widget.asset.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename asset'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onRename(controller.text.trim());
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
