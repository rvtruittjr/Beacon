import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/platform_adaptive/adaptive_dialog.dart';
import '../../models/social_account_model.dart';
import '../../providers/audience_provider.dart';

class SocialAccountsSection extends ConsumerWidget {
  const SocialAccountsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(socialAccountsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'SOCIAL ACCOUNTS',
              style: AppFonts.inter(fontSize: 12, color: mutedColor)
                  .copyWith(fontWeight: FontWeight.w600, letterSpacing: 1.2),
            ),
            const Spacer(),
            AppButton(
              label: 'Add account',
              icon: Icons.add,
              variant: AppButtonVariant.ghost,
              onPressed: () => _showAccountDialog(context, ref),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        accountsAsync.when(
          loading: () => const SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (_, __) => Text(
            'Failed to load accounts',
            style: AppFonts.inter(fontSize: 13, color: mutedColor),
          ),
          data: (accounts) {
            if (accounts.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.all(AppRadius.lg),
                ),
                child: Column(
                  children: [
                    Icon(LucideIcons.link, size: 28, color: mutedColor),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Link your social media accounts',
                      style: AppFonts.inter(fontSize: 14, color: mutedColor),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: accounts.map((account) {
                return _AccountRow(
                  account: account,
                  onEdit: () =>
                      _showAccountDialog(context, ref, existing: account),
                  onDelete: () async {
                    await ref
                        .read(socialAccountRepositoryProvider)
                        .deleteAccount(account.id!);
                    ref.invalidate(socialAccountsProvider);
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  void _showAccountDialog(
    BuildContext context,
    WidgetRef ref, {
    SocialAccountModel? existing,
  }) {
    AdaptiveDialog.show(
      context: context,
      child: _AccountDialog(
        existing: existing,
        onSave: (platform, username, displayName, followerCount) async {
          final brandId = ref.read(currentBrandProvider);
          if (brandId == null) return;

          if (existing != null) {
            await ref.read(socialAccountRepositoryProvider).updateAccount(
                  existing.id!,
                  platform: platform,
                  username: username,
                  displayName: displayName,
                  followerCount: followerCount,
                );
          } else {
            await ref.read(socialAccountRepositoryProvider).addAccount(
                  brandId: brandId,
                  platform: platform,
                  username: username,
                  displayName: displayName,
                  followerCount: followerCount,
                );
          }
          ref.invalidate(socialAccountsProvider);
        },
      ),
    );
  }
}

// ─── Account row ──────────────────────────────────────────────

class _AccountRow extends StatefulWidget {
  const _AccountRow({
    required this.account,
    required this.onEdit,
    required this.onDelete,
  });

  final SocialAccountModel account;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_AccountRow> createState() => _AccountRowState();
}

class _AccountRowState extends State<_AccountRow> {
  bool _isHovered = false;

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final account = widget.account;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.all(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(
              _platformIcon(account.platform),
              size: 20,
              color: textColor,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        account.displayName ?? account.username,
                        style: AppFonts.inter(
                          fontSize: 14,
                          color: textColor,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        account.platform,
                        style: AppFonts.inter(fontSize: 12, color: mutedColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '@${account.username}',
                        style: AppFonts.inter(fontSize: 12, color: mutedColor),
                      ),
                      if (account.followerCount != null) ...[
                        const SizedBox(width: AppSpacing.md),
                        Icon(LucideIcons.users, size: 12, color: mutedColor),
                        const SizedBox(width: 4),
                        Text(
                          account.followerDisplay,
                          style:
                              AppFonts.inter(fontSize: 12, color: mutedColor),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (_isHovered) ...[
              IconButton(
                icon: Icon(Icons.edit_outlined, size: 16, color: mutedColor),
                onPressed: widget.onEdit,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, size: 16, color: mutedColor),
                onPressed: widget.onDelete,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Account dialog ───────────────────────────────────────────

class _AccountDialog extends StatefulWidget {
  const _AccountDialog({this.existing, required this.onSave});

  final SocialAccountModel? existing;
  final Future<void> Function(
    String platform,
    String username,
    String? displayName,
    int? followerCount,
  ) onSave;

  @override
  State<_AccountDialog> createState() => _AccountDialogState();
}

class _AccountDialogState extends State<_AccountDialog> {
  late String _selectedPlatform;
  late final TextEditingController _usernameController;
  late final TextEditingController _displayNameController;
  late final TextEditingController _followerController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedPlatform = widget.existing?.platform ?? 'Instagram';
    _usernameController =
        TextEditingController(text: widget.existing?.username ?? '');
    _displayNameController =
        TextEditingController(text: widget.existing?.displayName ?? '');
    _followerController = TextEditingController(
      text: widget.existing?.followerCount?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    _followerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.existing != null ? 'Edit Account' : 'Add Social Account',
            style: AppFonts.clashDisplay(fontSize: 24, color: textColor),
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String>(
            value: _selectedPlatform,
            decoration: const InputDecoration(labelText: 'Platform'),
            items: SocialAccountModel.platforms
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _selectedPlatform = v);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              hintText: 'e.g. johndoe',
              prefixText: '@',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _displayNameController,
            decoration: const InputDecoration(
              labelText: 'Display Name (optional)',
              hintText: 'e.g. John Doe',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _followerController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Followers / Subscribers (optional)',
              hintText: 'e.g. 12500',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: widget.existing != null ? 'Save' : 'Add',
            isLoading: _saving,
            onPressed:
                _usernameController.text.trim().isEmpty || _saving
                    ? null
                    : _save,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.onSave(
        _selectedPlatform,
        _usernameController.text.trim(),
        _displayNameController.text.trim().isEmpty
            ? null
            : _displayNameController.text.trim(),
        int.tryParse(_followerController.text.trim()),
      );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
