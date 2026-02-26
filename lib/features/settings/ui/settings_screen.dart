import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../core/config/design_tokens.dart';
import '../../../core/config/app_fonts.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.x2l,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Settings',
                style: AppFonts.clashDisplay(fontSize: 32, color: textColor),
              ),
              const SizedBox(height: AppSpacing.lg),
              const _ProfileSection(),
              const SizedBox(height: AppSpacing.lg),
              const _AppearanceSection(),
              const SizedBox(height: AppSpacing.lg),
              const _SubscriptionSection(),
              const SizedBox(height: AppSpacing.lg),
              const _LogOutSection(),
              const SizedBox(height: AppSpacing.lg),
              const _DangerZoneSection(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Profile Section ─────────────────────────────────────────────

class _ProfileSection extends ConsumerStatefulWidget {
  const _ProfileSection();

  @override
  ConsumerState<_ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends ConsumerState<_ProfileSection> {
  late TextEditingController _nameCtrl;
  bool _saving = false;
  bool _saved = false;
  String? _avatarUrl;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _initFromUser(Map<String, dynamic>? user) {
    if (_initialized || user == null) return;
    _initialized = true;
    _nameCtrl.text = user['display_name'] as String? ?? '';
    _avatarUrl = user['avatar_url'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final userAsync = ref.watch(currentUserProvider);
    final authUser = SupabaseService.client.auth.currentUser;

    return AppCard(
      variant: AppCardVariant.feature,
      blockColor: AppColors.blockYellow,
      headerTitle: 'Profile',
      child: userAsync.when(
        loading: () => const LoadingIndicator(),
        error: (_, __) => const Text('Failed to load profile.'),
        data: (user) {
          _initFromUser(user);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: GestureDetector(
                  onTap: _uploadAvatar,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: isDark
                            ? AppColors.surfaceMidDark
                            : AppColors.surfaceMidLight,
                        backgroundImage: _avatarUrl != null
                            ? NetworkImage(_avatarUrl!)
                            : null,
                        child: _avatarUrl == null
                            ? Icon(LucideIcons.user, size: 32, color: mutedColor)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.blockLime,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.camera,
                            size: 14,
                            color: AppColors.textOnLime,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Display Name
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Display Name'),
              ),
              const SizedBox(height: AppSpacing.md),

              // Email (read-only)
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: authUser?.email ?? '',
                  suffixIcon: Icon(LucideIcons.lock, size: 16, color: mutedColor),
                ),
                controller: TextEditingController(text: authUser?.email ?? ''),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Save button
              Row(
                children: [
                  AppButton(
                    label: _saved ? 'Saved!' : 'Save changes',
                    icon: _saved ? LucideIcons.check : null,
                    isLoading: _saving,
                    onPressed: _saving ? null : _saveProfile,
                  ),
                  if (_saved) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Icon(LucideIcons.check, size: 18, color: AppColors.success),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _uploadAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    final client = SupabaseService.client;
    final user = client.auth.currentUser;
    if (user == null) return;

    final path =
        '${user.id}/avatar/${DateTime.now().millisecondsSinceEpoch}_${file.name}';

    await client.storage.from('brand-assets').uploadBinary(
          path,
          file.bytes!,
          fileOptions: const FileOptions(upsert: true),
        );

    final url = client.storage.from('brand-assets').getPublicUrl(path);

    await client.from('users').update({'avatar_url': url}).eq('id', user.id);

    setState(() => _avatarUrl = url);
    ref.invalidate(currentUserProvider);
  }

  Future<void> _saveProfile() async {
    setState(() {
      _saving = true;
      _saved = false;
    });

    try {
      final client = SupabaseService.client;
      final user = client.auth.currentUser;
      if (user == null) return;

      await client.from('users').update({
        'display_name': _nameCtrl.text.trim(),
      }).eq('id', user.id);

      ref.invalidate(currentUserProvider);
      setState(() => _saved = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _saved = false);
      });
    } catch (_) {
      // Silently fail
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ── Appearance Section ──────────────────────────────────────────

class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentMode = ref.watch(themeModeProvider);

    return AppCard(
      variant: AppCardVariant.feature,
      blockColor: AppColors.blockViolet,
      headerTitle: 'Appearance',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color:
                  isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _ThemePillSelector(
            currentMode: currentMode,
            onChanged: (mode) {
              ref.read(themeModeProvider.notifier).setMode(mode);
            },
          ),
        ],
      ),
    );
  }
}

class _ThemePillSelector extends StatelessWidget {
  const _ThemePillSelector({
    required this.currentMode,
    required this.onChanged,
  });

  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceMidDark : AppColors.surfaceMidLight,
        borderRadius: BorderRadius.all(AppRadius.full),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pill(context, 'Dark', ThemeMode.dark, LucideIcons.moon, isDark),
          _pill(context, 'Light', ThemeMode.light, LucideIcons.sun, isDark),
          _pill(context, 'System', ThemeMode.system, LucideIcons.monitor, isDark),
        ],
      ),
    );
  }

  Widget _pill(
    BuildContext context,
    String label,
    ThemeMode mode,
    IconData icon,
    bool isDark,
  ) {
    final isActive = currentMode == mode;
    return GestureDetector(
      onTap: () => onChanged(mode),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
              : Colors.transparent,
          borderRadius: BorderRadius.all(AppRadius.full),
          boxShadow: isActive && !isDark ? AppShadows.sm : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive
                  ? (isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight)
                  : (isDark ? AppColors.mutedDark : AppColors.mutedLight),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight)
                    : (isDark ? AppColors.mutedDark : AppColors.mutedLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Subscription Section ────────────────────────────────────────

class _SubscriptionSection extends ConsumerWidget {
  const _SubscriptionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subAsync = ref.watch(subscriptionProvider);

    return AppCard(
      variant: AppCardVariant.feature,
      blockColor: AppColors.blockLime,
      headerTitle: 'Subscription',
      child: subAsync.when(
        loading: () => const LoadingIndicator(),
        error: (_, __) => const Text('Failed to load subscription info.'),
        data: (sub) {
          final plan = sub?['plan'] as String? ?? 'free';
          final isPro = plan != 'free';
          final nextBilling = sub?['current_period_end'] as String?;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan badge
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isPro
                          ? AppColors.blockViolet
                          : (isDark
                              ? AppColors.surfaceMidDark
                              : AppColors.surfaceMidLight),
                      borderRadius: BorderRadius.all(AppRadius.full),
                    ),
                    child: Text(
                      isPro ? 'Pro' : 'Free',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isPro ? AppColors.textOnViolet : textColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (nextBilling != null)
                    Text(
                      'Next billing: ${_formatDate(nextBilling)}',
                      style: TextStyle(fontSize: 12, color: mutedColor),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              AppButton(
                label: 'Manage subscription',
                variant: AppButtonVariant.secondary,
                icon: LucideIcons.creditCard,
                onPressed: () => context.go('/app/settings/subscription'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }
}

// ── Log Out Section ─────────────────────────────────────────────

class _LogOutSection extends ConsumerStatefulWidget {
  const _LogOutSection();

  @override
  ConsumerState<_LogOutSection> createState() => _LogOutSectionState();
}

class _LogOutSectionState extends ConsumerState<_LogOutSection> {
  bool _loggingOut = false;

  Future<void> _logOut() async {
    setState(() => _loggingOut = true);
    try {
      await ref.read(authRepositoryProvider).signOut();
    } catch (_) {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: _loggingOut ? 'Logging out…' : 'Log out',
      variant: AppButtonVariant.secondary,
      icon: _loggingOut ? null : LucideIcons.logOut,
      isLoading: _loggingOut,
      isFullWidth: true,
      onPressed: _loggingOut ? null : _logOut,
    );
  }
}

// ── Danger Zone Section ─────────────────────────────────────────

class _DangerZoneSection extends ConsumerWidget {
  const _DangerZoneSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      variant: AppCardVariant.feature,
      blockColor: AppColors.blockCoral,
      headerTitle: 'Danger Zone',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Permanently delete your account and all associated data. This action cannot be undone.',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.mutedDark
                  : AppColors.mutedLight,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Delete account',
            variant: AppButtonVariant.destructive,
            icon: LucideIcons.trash2,
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _DeleteConfirmDialog(),
    );
  }
}

class _DeleteConfirmDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_DeleteConfirmDialog> createState() =>
      _DeleteConfirmDialogState();
}

class _DeleteConfirmDialogState extends ConsumerState<_DeleteConfirmDialog> {
  final _confirmCtrl = TextEditingController();
  bool _deleting = false;

  @override
  void dispose() {
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _canDelete => _confirmCtrl.text.trim() == 'DELETE';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: const Text('Delete Account'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This will permanently delete your account, all brands, assets, and content. This action cannot be undone.',
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Type DELETE to confirm:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _confirmCtrl,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'DELETE',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        AppButton(
          label: 'Delete forever',
          variant: AppButtonVariant.destructive,
          isLoading: _deleting,
          onPressed: _canDelete && !_deleting ? _delete : null,
        ),
      ],
    );
  }

  Future<void> _delete() async {
    setState(() => _deleting = true);

    try {
      final client = SupabaseService.client;
      // Call RPC to delete user data, then sign out
      await client.rpc('delete_user_account');
      await client.auth.signOut();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      setState(() => _deleting = false);
    }
  }
}
