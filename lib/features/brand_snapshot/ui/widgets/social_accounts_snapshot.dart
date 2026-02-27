import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../audience/models/social_account_model.dart';

class SocialAccountsSnapshot extends StatelessWidget {
  const SocialAccountsSnapshot({super.key, required this.accounts});
  final List<SocialAccountModel> accounts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return AppCard(
      variant: AppCardVariant.feature,
      blockColor: AppColors.blockCoral,
      headerTitle: 'Social Accounts',
      child: accounts.isEmpty
          ? _buildEmpty(context, mutedColor)
          : _buildGrid(context, mutedColor),
    );
  }

  Widget _buildGrid(BuildContext context, Color mutedColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: accounts.map((account) {
        return _AccountChip(
          account: account,
          textColor: textColor,
          mutedColor: mutedColor,
        );
      }).toList(),
    );
  }

  Widget _buildEmpty(BuildContext context, Color mutedColor) {
    return Row(
      children: [
        Text(
          'No social accounts linked yet.',
          style: AppFonts.inter(fontSize: 14, color: mutedColor)
              .copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(width: AppSpacing.sm),
        TextButton(
          onPressed: () => context.go('/app/audience'),
          child: Text(
            'Add',
            style: AppFonts.inter(fontSize: 14, color: mutedColor),
          ),
        ),
      ],
    );
  }
}

class _AccountChip extends StatelessWidget {
  const _AccountChip({
    required this.account,
    required this.textColor,
    required this.mutedColor,
  });

  final SocialAccountModel account;
  final Color textColor;
  final Color mutedColor;

  IconData _platformIcon(String platform) {
    return switch (platform) {
      'Instagram' => LucideIcons.instagram,
      'TikTok' => LucideIcons.music2,
      'YouTube' => LucideIcons.youtube,
      'X (Twitter)' => LucideIcons.twitter,
      'LinkedIn' => LucideIcons.linkedin,
      'Facebook' => LucideIcons.facebook,
      'Pinterest' => LucideIcons.compass,
      'Threads' => LucideIcons.atSign,
      'Twitch' => LucideIcons.twitch,
      'Substack' => LucideIcons.mail,
      _ => LucideIcons.globe,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: mutedColor.withValues(alpha: 0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.all(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _platformIcon(account.platform),
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            account.displayName ?? '@${account.username}',
            style: AppFonts.inter(
              fontSize: 13,
              color: textColor,
            ).copyWith(fontWeight: FontWeight.w500),
          ),
          if (account.followerCount != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              account.followerDisplay,
              style: AppFonts.inter(fontSize: 12, color: mutedColor),
            ),
          ],
        ],
      ),
    );
  }
}
