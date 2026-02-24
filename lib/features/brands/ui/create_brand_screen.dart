import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/design_tokens.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/platform_adaptive/adaptive_dialog.dart';
import '../../auth/ui/onboarding/onboarding_state.dart';
import '../providers/brand_provider.dart';

class CreateBrandScreen extends ConsumerStatefulWidget {
  const CreateBrandScreen({super.key});

  static Future<void> show(BuildContext context, WidgetRef ref) {
    return AdaptiveDialog.show(
      context: context,
      child: const CreateBrandScreen(),
    );
  }

  @override
  ConsumerState<CreateBrandScreen> createState() => _CreateBrandScreenState();
}

class _CreateBrandScreenState extends ConsumerState<CreateBrandScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _isUpgradeRequired = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Brand name is required.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final existingBrands = ref.read(userBrandsProvider).valueOrNull ?? [];

      final brand = await ref.read(brandRepositoryProvider).createBrand(
            name: name,
            description: _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null,
          );

      if (!mounted) return;

      ref.read(currentBrandProvider.notifier).state = brand.id;
      ref.invalidate(userBrandsProvider);

      Navigator.of(context).pop();

      if (existingBrands.isEmpty) {
        // Seed brand name so Done step can show it in the preview card
        ref.read(onboardingProvider.notifier).setBrandName(name);
        context.go('/onboarding');
      } else {
        context.go('/app/snapshot');
      }
    } on UpgradeRequiredException {
      if (!mounted) return;
      setState(() {
        _isUpgradeRequired = true;
        _isLoading = false;
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isUpgradeRequired) {
      return _buildUpgradePrompt(theme);
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create a new brand',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _nameController,
            label: 'Brand Name',
            hint: 'e.g. My Creator Brand',
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _descriptionController,
            label: 'Description',
            hint: 'What is this brand about? (optional)',
            maxLines: 3,
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Create brand',
            onPressed: _create,
            isLoading: _isLoading,
            isFullWidth: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradePrompt(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lock_outline,
            size: 48,
            color: AppColors.blockYellow,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Upgrade to Pro',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Free plan is limited to 1 brand. Upgrade to create unlimited brands.',
            style: theme.textTheme.bodyMedium?.copyWith(color: mutedColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'View plans',
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/app/settings');
            },
            isFullWidth: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Maybe later'),
            ),
          ),
        ],
      ),
    );
  }
}
