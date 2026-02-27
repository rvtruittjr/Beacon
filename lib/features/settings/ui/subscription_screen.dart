import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/config/design_tokens.dart';
import '../../../core/config/app_fonts.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/stripe_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/loading_indicator.dart';

/// Billing interval toggle state.
final _billingIntervalProvider = StateProvider<String>((ref) => 'month');

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  static const _features = [
    _FeatureRow('Brands', '1', 'Unlimited'),
    _FeatureRow('Asset storage', '250 MB', '50 GB'),
    _FeatureRow('Asset library', '10 items', 'Unlimited'),
    _FeatureRow('Content archive', '5 items', 'Unlimited'),
    _FeatureRow('Archive video upload', null, '✓'),
    _FeatureRow('Password-protected links', null, '✓'),
    _FeatureRow('Link expiry', null, '✓'),
    _FeatureRow('Access log', null, '✓'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subAsync = ref.watch(subscriptionProvider);
    final interval = ref.watch(_billingIntervalProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.x2l,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Subscription',
                style: AppFonts.clashDisplay(fontSize: 32, color: textColor),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Billing interval toggle
              Center(child: _IntervalToggle(interval: interval)),
              const SizedBox(height: AppSpacing.lg),

              // Plan cards
              subAsync.when(
                loading: () => const LoadingIndicator(),
                error: (_, __) =>
                    const Text('Failed to load subscription info.'),
                data: (sub) {
                  final currentPlan =
                      sub?['plan'] as String? ?? 'free';
                  final customerId =
                      sub?['stripe_customer_id'] as String?;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 600;

                      final freeCard = _FreePlanCard(
                        isCurrent: currentPlan == 'free',
                      );
                      final proCard = _ProPlanCard(
                        isCurrent: currentPlan != 'free',
                        interval: interval,
                        customerId: customerId,
                      );

                      if (isWide) {
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: freeCard),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(child: proCard),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: [
                          freeCard,
                          const SizedBox(height: AppSpacing.md),
                          proCard,
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: AppSpacing.x2l),

              // Feature comparison table
              _FeatureComparisonTable(features: _features),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Interval Toggle ─────────────────────────────────────────────

class _IntervalToggle extends ConsumerWidget {
  const _IntervalToggle({required this.interval});
  final String interval;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.all(AppRadius.full),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _intervalPill(context, ref, 'Monthly', 'month', isDark),
          _intervalPill(context, ref, 'Yearly', 'year', isDark),
        ],
      ),
    );
  }

  Widget _intervalPill(
    BuildContext context,
    WidgetRef ref,
    String label,
    String value,
    bool isDark,
  ) {
    final isActive = interval == value;
    return GestureDetector(
      onTap: () =>
          ref.read(_billingIntervalProvider.notifier).state = value,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.surface
              : Colors.transparent,
          borderRadius: BorderRadius.all(AppRadius.full),
          boxShadow: isActive && !isDark ? AppShadows.sm : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight)
                    : (isDark ? AppColors.mutedDark : AppColors.mutedLight),
              ),
            ),
            if (value == 'year') ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.all(AppRadius.full),
                ),
                child: Text(
                  'Save 31%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Free Plan Card ──────────────────────────────────────────────

class _FreePlanCard extends StatelessWidget {
  const _FreePlanCard({required this.isCurrent});
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.all(AppRadius.lg),
        border: Border.all(
          color: theme.colorScheme.outline,
        ),
        boxShadow: isDark ? null : AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Free',
                style: AppFonts.clashDisplay(fontSize: 24, color: textColor),
              ),
              if (isCurrent) ...[
                const SizedBox(width: AppSpacing.sm),
                _CurrentPlanBadge(),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '\$0',
            style: AppFonts.clashDisplay(fontSize: 32, color: textColor),
          ),
          Text('forever', style: TextStyle(fontSize: 13, color: mutedColor)),
          const SizedBox(height: AppSpacing.lg),

          // Feature list
          _featureItem('1 brand', true, textColor, mutedColor),
          _featureItem('250 MB storage', true, textColor, mutedColor),
          _featureItem('10 asset library items', true, textColor, mutedColor),
          _featureItem('5 archive items', true, textColor, mutedColor),
          _featureItem('Video upload', false, textColor, mutedColor),
          _featureItem('Password-protected links', false, textColor, mutedColor),
          _featureItem('Link expiry', false, textColor, mutedColor),
          _featureItem('Access log', false, textColor, mutedColor),
        ],
      ),
    );
  }

  Widget _featureItem(
      String label, bool included, Color textColor, Color mutedColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            included ? LucideIcons.check : LucideIcons.x,
            size: 16,
            color: included ? AppColors.success : mutedColor,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: included ? textColor : mutedColor,
              decoration:
                  included ? null : TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pro Plan Card ───────────────────────────────────────────────

class _ProPlanCard extends ConsumerStatefulWidget {
  const _ProPlanCard({
    required this.isCurrent,
    required this.interval,
    this.customerId,
  });

  final bool isCurrent;
  final String interval;
  final String? customerId;

  @override
  ConsumerState<_ProPlanCard> createState() => _ProPlanCardState();
}

class _ProPlanCardState extends ConsumerState<_ProPlanCard> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    final price = widget.interval == 'year' ? '\$99' : '\$12';
    final period = widget.interval == 'year' ? '/year' : '/month';

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.all(AppRadius.lg),
        border: Border.all(color: AppColors.blockViolet, width: 2),
        boxShadow: isDark ? null : AppShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.blockViolet,
              borderRadius: BorderRadius.all(AppRadius.full),
            ),
            child: const Text(
              'Pro',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textOnViolet,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Price
          AnimatedSwitcher(
            duration: AppDurations.fast,
            child: Row(
              key: ValueKey(widget.interval),
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style:
                      AppFonts.clashDisplay(fontSize: 32, color: textColor),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    period,
                    style: TextStyle(fontSize: 14, color: mutedColor),
                  ),
                ),
              ],
            ),
          ),
          if (widget.interval == 'year')
            Text(
              'That\'s \$8.25/month',
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary),
            ),
          const SizedBox(height: AppSpacing.lg),

          // Feature list
          _featureItem('Unlimited brands', textColor),
          _featureItem('50 GB storage', textColor),
          _featureItem('Unlimited library items', textColor),
          _featureItem('Unlimited archive items', textColor),
          _featureItem('Video upload', textColor),
          _featureItem('Password-protected links', textColor),
          _featureItem('Link expiry', textColor),
          _featureItem('Access log', textColor),

          const SizedBox(height: AppSpacing.lg),

          // CTA
          if (widget.isCurrent) ...[
            Row(
              children: [
                _CurrentPlanBadge(),
                const Spacer(),
                if (widget.customerId != null)
                  AppButton(
                    label: 'Manage billing',
                    variant: AppButtonVariant.ghost,
                    onPressed: () =>
                        StripeService.openBillingPortal(widget.customerId!),
                  ),
              ],
            ),
          ] else
            AppButton(
              label: 'Get Pro',
              icon: LucideIcons.sparkles,
              isLoading: _loading,
              isFullWidth: true,
              onPressed: _loading ? null : _startCheckout,
            ),
        ],
      ),
    );
  }

  Widget _featureItem(String label, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(LucideIcons.check, size: 16, color: AppColors.success),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: TextStyle(fontSize: 13, color: textColor)),
        ],
      ),
    );
  }

  Future<void> _startCheckout() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return;

    setState(() => _loading = true);

    try {
      final sessionUrl = await StripeService.createCheckoutSession(
        userId: user.id,
        plan: 'pro',
        interval: widget.interval,
      );
      await StripeService.openCheckoutUrl(sessionUrl);

      // Refresh subscription status after returning
      ref.invalidate(subscriptionProvider);
    } catch (_) {
      // Handle error silently
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

// ── Current Plan Badge ──────────────────────────────────────────

class _CurrentPlanBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.all(AppRadius.full),
      ),
      child: Text(
        'Current plan',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

// ── Feature Comparison Table ────────────────────────────────────

class _FeatureRow {
  const _FeatureRow(this.feature, this.free, this.pro);
  final String feature;
  final String? free; // null = ✗
  final String pro;
}

class _FeatureComparisonTable extends StatelessWidget {
  const _FeatureComparisonTable({required this.features});
  final List<_FeatureRow> features;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final borderColor = theme.colorScheme.outline;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.all(AppRadius.lg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius:
                  const BorderRadius.vertical(top: AppRadius.lg),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Feature',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Free',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Pro',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blockViolet,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Data rows
          ...features.map((f) {
            final isLast = f == features.last;
            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: 12),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(bottom: BorderSide(color: borderColor, width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      f.feature,
                      style: TextStyle(fontSize: 13, color: textColor),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: f.free != null
                          ? Text(
                              f.free!,
                              style:
                                  TextStyle(fontSize: 13, color: mutedColor),
                            )
                          : Icon(LucideIcons.x, size: 16, color: mutedColor),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: f.pro == '✓'
                          ? const Icon(LucideIcons.check,
                              size: 16, color: AppColors.success)
                          : Text(
                              f.pro,
                              style: TextStyle(
                                fontSize: 13,
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
