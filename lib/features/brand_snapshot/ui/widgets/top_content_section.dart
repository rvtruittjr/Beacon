import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_badge.dart';

class TopContentSection extends StatelessWidget {
  const TopContentSection({super.key, required this.items});
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return AppCard(
      variant: AppCardVariant.feature,
      blockColor: AppColors.blockCoral,
      headerTitle: 'Top Content',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (items.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go('/app/archive'),
                child: Text(
                  'View all',
                  style: AppFonts.inter(fontSize: 13, color: mutedColor),
                ),
              ),
            ),
          items.isEmpty
              ? _buildEmpty(context, mutedColor)
              : SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) =>
                        _ArchiveCardCompact(item: items[index]),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, Color mutedColor) {
    return Row(
      children: [
        Text(
          'No content archived yet.',
          style: AppFonts.inter(fontSize: 14, color: mutedColor)
              .copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(width: AppSpacing.sm),
        TextButton(
          onPressed: () => context.go('/app/archive'),
          child: Text(
            'Add',
            style: AppFonts.inter(fontSize: 14, color: mutedColor),
          ),
        ),
      ],
    );
  }
}

class _ArchiveCardCompact extends StatelessWidget {
  const _ArchiveCardCompact({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    final title = item['title'] as String? ?? 'Untitled';
    final platform = item['platform'] as String?;
    final thumbnailUrl = item['thumbnail_url'] as String?;
    final views = item['views'] as num?;

    return Container(
      width: 180,
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
            child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: thumbnailUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.surfaceMidDark,
                      child: Icon(Icons.play_circle_outline,
                          color: mutedColor, size: 32),
                    ),
                  )
                : Container(
                    color: isDark
                        ? AppColors.surfaceMidDark
                        : AppColors.surfaceMidLight,
                    child: Icon(Icons.play_circle_outline,
                        color: mutedColor, size: 32),
                  ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (platform != null)
                      AppBadge(
                        label: platform,
                        variant: AppBadgeVariant.platform,
                        platformName: platform,
                      ),
                    const Spacer(),
                    if (views != null)
                      Text(
                        _formatViews(views),
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatViews(num views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M views';
    }
    if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K views';
    }
    return '$views views';
  }
}
