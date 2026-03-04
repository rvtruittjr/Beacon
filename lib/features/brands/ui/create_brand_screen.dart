import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_fonts.dart';
import '../../../core/config/design_tokens.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/platform_adaptive/adaptive_dialog.dart';
import '../../auth/ui/onboarding/onboarding_state.dart';
import '../../brand_kit/models/brand_kit_template.dart';
import '../../brand_kit/ui/widgets/template_picker.dart';
import '../../brand_kit/providers/brand_kit_provider.dart';
import '../../brand_kit/services/template_service.dart';
import '../../audience/providers/audience_provider.dart';
import '../../content_pillars/data/content_pillar_repository.dart';
import '../../content_pillars/providers/content_pillar_provider.dart' show contentPillarsListProvider;
import '../../voice_tone/providers/voice_provider.dart';
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
  int _step = 1; // 1 = name, 2 = template picker
  String? _createdBrandId;
  bool _wasFirstBrand = false;

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

      _createdBrandId = brand.id;
      _wasFirstBrand = existingBrands.isEmpty;

      if (_wasFirstBrand) {
        ref.read(onboardingProvider.notifier).setBrandName(name);
      }

      setState(() {
        _step = 2;
        _isLoading = false;
      });
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

    if (_step == 2) {
      return _buildTemplatePicker(theme);
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

  void _navigateAfterCreate() {
    Navigator.of(context).pop();
    if (_wasFirstBrand) {
      context.go('/onboarding');
    } else {
      context.go('/app/snapshot');
    }
  }

  Future<void> _applyTemplate(BrandKitTemplate template) async {
    if (_createdBrandId == null) return;

    setState(() => _isLoading = true);

    try {
      final service = TemplateService(
        colorsRepo: ref.read(colorsRepositoryProvider),
        fontsRepo: ref.read(fontsRepositoryProvider),
        voiceRepo: ref.read(voiceRepositoryProvider),
        audienceRepo: ref.read(audienceRepositoryProvider),
        pillarRepo: ref.read(contentPillarRepositoryProvider),
      );

      await service.applyTemplate(_createdBrandId!, template);

      // Invalidate all providers so the UI refreshes
      ref.invalidate(brandColorsProvider);
      ref.invalidate(brandFontsProvider);
      ref.invalidate(voiceProvider);
      ref.invalidate(audienceProvider);
      ref.invalidate(contentPillarsListProvider);

      if (!mounted) return;
      _navigateAfterCreate();
    } catch (_) {
      if (!mounted) return;
      // Template failed but brand was created — navigate anyway
      _navigateAfterCreate();
    }
  }

  Widget _buildTemplatePicker(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.lg),
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Applying template...',
              style: AppFonts.inter(fontSize: 14, color: mutedColor),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 520),
        child: SingleChildScrollView(
          child: TemplatePicker(
            onSelected: _applyTemplate,
            onSkip: _navigateAfterCreate,
          ),
        ),
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
