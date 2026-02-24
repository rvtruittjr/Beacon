import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/config/design_tokens.dart';
import '../../../core/config/app_fonts.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../data/share_repository.dart';
import '../providers/share_provider.dart';

class ShareSettingsScreen extends ConsumerWidget {
  const ShareSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(shareSettingsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
                'Sharing',
                style: AppFonts.clashDisplay(fontSize: 32, color: textColor),
              ),
              const SizedBox(height: AppSpacing.lg),

              settingsAsync.when(
                loading: () => const LoadingIndicator(),
                error: (_, __) => const Text('Failed to load share settings.'),
                data: (brand) {
                  if (brand == null) {
                    return const Text('No brand selected.');
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ShareLinkSection(brand: brand),
                      const SizedBox(height: AppSpacing.lg),
                      _PasswordSection(brand: brand),
                      const SizedBox(height: AppSpacing.lg),
                      _ExpirySection(brand: brand),
                      const SizedBox(height: AppSpacing.lg),
                      _AccessLogSection(),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Share Link Section ──────────────────────────────────────────

class _ShareLinkSection extends ConsumerStatefulWidget {
  const _ShareLinkSection({required this.brand});
  final dynamic brand;

  @override
  ConsumerState<_ShareLinkSection> createState() => _ShareLinkSectionState();
}

class _ShareLinkSectionState extends ConsumerState<_ShareLinkSection> {
  bool _copied = false;

  String get _shareUrl =>
      'https://beakon.app/share/${widget.brand.shareToken}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return AppCard(
      variant: AppCardVariant.feature,
      blockColor: AppColors.blockViolet,
      headerTitle: 'Share Link',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle
          SwitchListTile(
            title: const Text('Enable sharing'),
            subtitle: Text(
              widget.brand.isPublic
                  ? 'Anyone with the link can view your brand kit'
                  : 'Your brand kit is private',
              style: TextStyle(color: mutedColor, fontSize: 13),
            ),
            value: widget.brand.isPublic,
            activeColor: AppColors.blockLime,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) async {
              final brandId = ref.read(currentBrandProvider);
              if (brandId == null) return;
              await ref
                  .read(shareRepositoryProvider)
                  .updateShareSettings(brandId, isPublic: val);
              ref.invalidate(shareSettingsProvider);
            },
          ),

          if (widget.brand.isPublic) ...[
            const SizedBox(height: AppSpacing.md),

            // Share URL
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceMidDark
                    : AppColors.surfaceMidLight,
                borderRadius: BorderRadius.all(AppRadius.md),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _shareUrl,
                      style: TextStyle(fontSize: 13, color: mutedColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  TextButton.icon(
                    onPressed: _copyLink,
                    icon: Icon(
                      _copied ? LucideIcons.check : LucideIcons.copy,
                      size: 16,
                    ),
                    label: Text(_copied ? 'Copied!' : 'Copy'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // QR code
            Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(AppRadius.lg),
                ),
                child: QrImageView(
                  data: _shareUrl,
                  version: QrVersions.auto,
                  size: 160,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Reset link
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _confirmResetLink(context),
                icon: const Icon(LucideIcons.rotateCcw, size: 16),
                label: const Text('Reset link'),
                style: TextButton.styleFrom(foregroundColor: mutedColor),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: _shareUrl));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  void _confirmResetLink(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset share link?'),
        content: const Text(
          'This will generate a new URL and invalidate the old one. Anyone with the old link will lose access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final brandId = ref.read(currentBrandProvider);
              if (brandId == null) return;
              await ref
                  .read(shareRepositoryProvider)
                  .resetShareToken(brandId);
              ref.invalidate(shareSettingsProvider);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

// ── Password Section (Pro only) ─────────────────────────────────

class _PasswordSection extends ConsumerStatefulWidget {
  const _PasswordSection({required this.brand});
  final dynamic brand;

  @override
  ConsumerState<_PasswordSection> createState() => _PasswordSectionState();
}

class _PasswordSectionState extends ConsumerState<_PasswordSection> {
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool get _isPro {
    final sub = ref.read(subscriptionProvider).valueOrNull;
    return (sub?['plan'] as String? ?? 'free') != 'free';
  }

  bool get _hasPassword => widget.brand.sharePasswordHash != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return AppCard(
      variant: AppCardVariant.feature,
      blockColor: AppColors.blockViolet,
      headerTitle: 'Password Protection',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isPro) ...[
            _ProFeatureBanner(),
          ] else ...[
            SwitchListTile(
              title: const Text('Require password'),
              value: _hasPassword,
              activeColor: AppColors.blockLime,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) async {
                if (!val) {
                  final brandId = ref.read(currentBrandProvider);
                  if (brandId == null) return;
                  await ref
                      .read(shareRepositoryProvider)
                      .clearPassword(brandId);
                  ref.invalidate(shareSettingsProvider);
                }
              },
            ),
            if (_hasPassword || !_hasPassword) ...[
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? LucideIcons.eyeOff : LucideIcons.eye,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Set password',
                onPressed: () async {
                  final pw = _passwordCtrl.text.trim();
                  if (pw.isEmpty) return;
                  final brandId = ref.read(currentBrandProvider);
                  if (brandId == null) return;
                  await ref
                      .read(shareRepositoryProvider)
                      .updateShareSettings(brandId, password: pw);
                  ref.invalidate(shareSettingsProvider);
                  _passwordCtrl.clear();
                },
              ),
            ],
          ],
        ],
      ),
    );
  }
}

// ── Expiry Section (Pro only) ───────────────────────────────────

class _ExpirySection extends ConsumerWidget {
  const _ExpirySection({required this.brand});
  final dynamic brand;

  bool _isPro(WidgetRef ref) {
    final sub = ref.read(subscriptionProvider).valueOrNull;
    return (sub?['plan'] as String? ?? 'free') != 'free';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final hasExpiry = brand.shareExpiresAt != null;

    return AppCard(
      variant: AppCardVariant.feature,
      blockColor: AppColors.blockViolet,
      headerTitle: 'Link Expiry',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isPro(ref)) ...[
            _ProFeatureBanner(),
          ] else ...[
            SwitchListTile(
              title: const Text('Set expiry date'),
              value: hasExpiry,
              activeColor: AppColors.blockLime,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) async {
                final brandId = ref.read(currentBrandProvider);
                if (brandId == null) return;
                if (!val) {
                  await ref
                      .read(shareRepositoryProvider)
                      .clearExpiry(brandId);
                  ref.invalidate(shareSettingsProvider);
                } else {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate:
                        DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    await ref
                        .read(shareRepositoryProvider)
                        .updateShareSettings(brandId, expiresAt: picked);
                    ref.invalidate(shareSettingsProvider);
                  }
                }
              },
            ),
            if (hasExpiry) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _expiryLabel(brand.shareExpiresAt!),
                style: TextStyle(color: mutedColor, fontSize: 13),
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _expiryLabel(DateTime expiry) {
    final diff = expiry.difference(DateTime.now());
    if (diff.isNegative) return 'Link has expired';
    if (diff.inDays > 0) return 'Link expires in ${diff.inDays} days';
    if (diff.inHours > 0) return 'Link expires in ${diff.inHours} hours';
    return 'Link expires soon';
  }
}

// ── Access Log Section (Pro only) ───────────────────────────────

class _AccessLogSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final sub = ref.read(subscriptionProvider).valueOrNull;
    final isPro = (sub?['plan'] as String? ?? 'free') != 'free';

    if (!isPro) return const SizedBox.shrink();

    final logAsync = ref.watch(accessLogProvider);

    return AppCard(
      variant: AppCardVariant.feature,
      blockColor: AppColors.blockViolet,
      headerTitle: 'Access Log',
      child: logAsync.when(
        loading: () => const LoadingIndicator(),
        error: (_, __) => const Text('Failed to load access log.'),
        data: (entries) {
          if (entries.isEmpty) {
            return Text(
              'No access log entries yet.',
              style: TextStyle(
                  color: mutedColor, fontSize: 13, fontStyle: FontStyle.italic),
            );
          }

          return Column(
            children: entries.map((entry) {
              final isGranted = entry.status == 'granted';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      isGranted ? LucideIcons.checkCircle : LucideIcons.xCircle,
                      size: 16,
                      color: isGranted ? AppColors.success : AppColors.blockCoral,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        entry.ipAddress ?? 'Unknown',
                        style: TextStyle(fontSize: 13, color: textColor),
                      ),
                    ),
                    Text(
                      _formatTimestamp(entry.accessedAt),
                      style: TextStyle(fontSize: 12, color: mutedColor),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ── Pro feature banner ──────────────────────────────────────────

class _ProFeatureBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.blockCoral.withValues(alpha: 0.1),
        borderRadius: BorderRadius.all(AppRadius.lg),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.sparkles, color: AppColors.blockCoral, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Unlock password protection and link expiry with Pro.',
              style: AppFonts.inter(fontSize: 13, color: AppColors.blockCoral),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppButton(
            label: 'Upgrade',
            onPressed: () {
              // TODO: upgrade flow
            },
          ),
        ],
      ),
    );
  }
}
