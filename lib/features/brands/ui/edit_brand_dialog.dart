import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/design_tokens.dart';
import '../../../core/errors/app_exception.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/platform_adaptive/adaptive_dialog.dart';
import '../../brand_snapshot/providers/snapshot_provider.dart';
import '../models/brand_model.dart';
import '../providers/brand_provider.dart';

class EditBrandDialog extends ConsumerStatefulWidget {
  const EditBrandDialog({super.key, required this.brand});
  final BrandModel brand;

  static Future<void> show(BuildContext context, BrandModel brand) {
    return AdaptiveDialog.show(
      context: context,
      child: EditBrandDialog(brand: brand),
    );
  }

  @override
  ConsumerState<EditBrandDialog> createState() => _EditBrandDialogState();
}

class _EditBrandDialogState extends ConsumerState<EditBrandDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.brand.name);
    _descriptionController = TextEditingController(
      text: widget.brand.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
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
      await ref.read(brandRepositoryProvider).updateBrand(
            widget.brand.id,
            name: name,
            description: _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null,
          );

      if (!mounted) return;

      ref.invalidate(userBrandsProvider);
      ref.invalidate(activeBrandProvider);
      ref.invalidate(snapshotProvider);

      Navigator.of(context).pop();
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

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Edit brand',
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
            label: 'Save changes',
            onPressed: _save,
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
}
