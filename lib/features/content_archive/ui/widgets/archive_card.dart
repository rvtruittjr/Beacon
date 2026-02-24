import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../models/archive_item_model.dart';

// ── Platform brand colors for placeholder thumbnails ────────────

Color _platformColor(String? platform) {
  return switch (platform?.toLowerCase()) {
    'youtube' => const Color(0xFFFF0000),
    'tiktok' => const Color(0xFF1A1A1A),
    'instagram' => const Color(0xFFE1306C),
    'twitter' || 'x' => const Color(0xFF1DA1F2),
    'newsletter' => const Color(0xFF6C63FF),
    'podcast' => const Color(0xFF8B5CF6),
    _ => AppColors.blockCoral,
  };
}

Color _parseHex(String hex) {
  final clean = hex.replaceFirst('#', '');
  if (clean.length == 6 && RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(clean)) {
    return Color(int.parse('FF$clean', radix: 16));
  }
  return AppColors.blockViolet;
}

// ── Standard variant ────────────────────────────────────────────

class ArchiveCard extends StatefulWidget {
  const ArchiveCard({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
  });

  final ArchiveItemModel item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  State<ArchiveCard> createState() => _ArchiveCardState();
}

class _ArchiveCardState extends State<ArchiveCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final item = widget.item;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onSecondaryTapUp: (details) =>
            _showContextMenu(context, details.globalPosition),
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.all(AppRadius.lg),
            boxShadow: isDark ? null : AppShadows.sm,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Thumbnail area
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildThumbnail(item, mutedColor),
                    // Platform badge (top-left)
                    if (item.platform != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: AppBadge(
                          label: item.platform!,
                          variant: AppBadgeVariant.platform,
                          platformName: item.platform,
                        ),
                      ),
                    // Pillar chip (top-right)
                    if (item.pillarName != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: item.pillarColor != null
                                ? _parseHex(item.pillarColor!)
                                : AppColors.blockViolet,
                            borderRadius: BorderRadius.all(AppRadius.full),
                          ),
                          child: Text(
                            item.pillarName!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    // Video play overlay (pro)
                    if (item.videoUrl != null && item.videoUrl!.isNotEmpty)
                      const Center(
                        child: Icon(
                          LucideIcons.playCircle,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    // Hover notes tooltip
                    if (_hovered &&
                        item.notes != null &&
                        item.notes!.isNotEmpty)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.black.withValues(alpha: 0.75),
                          child: Text(
                            item.notes!.length > 100
                                ? '${item.notes!.substring(0, 100)}…'
                                : item.notes!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Card body
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      item.title,
                      style: AppFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Hook snippet
                    if (item.hook != null && item.hook!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.hook!,
                        style: AppFonts.inter(fontSize: 13, color: mutedColor)
                            .copyWith(fontStyle: FontStyle.italic),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Engagement stats row
                    Row(
                      children: [
                        if (item.views != null) ...[
                          Icon(LucideIcons.eye, size: 14, color: mutedColor),
                          const SizedBox(width: 3),
                          Text(
                            ArchiveItemModel.compact(item.views!),
                            style: TextStyle(fontSize: 12, color: mutedColor),
                          ),
                          const SizedBox(width: 10),
                        ],
                        if (item.likes != null) ...[
                          Icon(LucideIcons.heart, size: 14, color: mutedColor),
                          const SizedBox(width: 3),
                          Text(
                            ArchiveItemModel.compact(item.likes!),
                            style: TextStyle(fontSize: 12, color: mutedColor),
                          ),
                          const SizedBox(width: 10),
                        ],
                        if (item.comments != null) ...[
                          Icon(LucideIcons.messageCircle,
                              size: 14, color: mutedColor),
                          const SizedBox(width: 3),
                          Text(
                            ArchiveItemModel.compact(item.comments!),
                            style: TextStyle(fontSize: 12, color: mutedColor),
                          ),
                        ],
                        const Spacer(),
                        if (item.datePosted != null)
                          Text(
                            _formatDate(item.datePosted!),
                            style: TextStyle(fontSize: 11, color: mutedColor),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(ArchiveItemModel item, Color mutedColor) {
    if (item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: item.thumbnailUrl!,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) =>
            _placeholderThumbnail(item.platform, mutedColor),
      );
    }
    return _placeholderThumbnail(item.platform, mutedColor);
  }

  Widget _placeholderThumbnail(String? platform, Color mutedColor) {
    return Container(
      color: _platformColor(platform).withValues(alpha: 0.15),
      child: Center(
        child: Icon(LucideIcons.image, size: 32, color: mutedColor),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showContextMenu(BuildContext context, Offset position) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx, position.dy, position.dx, position.dy),
      items: const [
        PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    ).then((value) {
      if (value == 'edit') widget.onEdit?.call();
      if (value == 'delete') widget.onDelete?.call();
    });
  }
}

// ── Compact variant (for Snapshot Top Content row) ──────────────

class ArchiveCardCompact extends StatelessWidget {
  const ArchiveCardCompact({super.key, required this.item});
  final ArchiveItemModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Container(
      width: 160,
      height: 200,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.all(AppRadius.lg),
        boxShadow: isDark ? null : AppShadows.sm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          SizedBox(
            height: 100,
            width: double.infinity,
            child: item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: item.thumbnailUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: _platformColor(item.platform)
                          .withValues(alpha: 0.15),
                      child: Icon(LucideIcons.image,
                          size: 24, color: mutedColor),
                    ),
                  )
                : Container(
                    color:
                        _platformColor(item.platform).withValues(alpha: 0.15),
                    child:
                        Icon(LucideIcons.image, size: 24, color: mutedColor),
                  ),
          ),
          // Platform badge
          if (item.platform != null)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: AppBadge(
                label: item.platform!,
                variant: AppBadgeVariant.platform,
                platformName: item.platform,
              ),
            ),
          // Title
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                item.title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
