import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/widgets/app_button.dart';

class AddInspirationItemDialog extends ConsumerStatefulWidget {
  const AddInspirationItemDialog({super.key});

  @override
  ConsumerState<AddInspirationItemDialog> createState() =>
      _AddInspirationItemDialogState();
}

class _AddInspirationItemDialogState
    extends ConsumerState<AddInspirationItemDialog> {
  final _urlController = TextEditingController();
  bool _uploading = false;
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _addFromUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _error = 'Please enter a URL');
      return;
    }
    Navigator.of(context).pop(url);
  }

  Future<void> _uploadImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() {
      _uploading = true;
      _error = null;
    });

    try {
      final user = SupabaseService.client.auth.currentUser;
      final brandId = ref.read(currentBrandProvider);
      if (user == null || brandId == null) return;

      final path =
          '${user.id}/$brandId/moodboard/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      await SupabaseService.client.storage.from('brand-assets').uploadBinary(
            path,
            file.bytes!,
            fileOptions: FileOptions(upsert: true),
          );

      final url =
          SupabaseService.client.storage.from('brand-assets').getPublicUrl(path);
      if (mounted) Navigator.of(context).pop(url);
    } catch (e) {
      if (mounted) setState(() => _error = 'Upload failed');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
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
            'Add to Board',
            style: AppFonts.clashDisplay(fontSize: 24, color: textColor),
          ),
          const SizedBox(height: AppSpacing.lg),

          // URL input
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Image URL',
              hintText: 'https://example.com/image.png',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(_error!, style: TextStyle(color: AppColors.error, fontSize: 12)),
          ],
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Add from URL',
            onPressed: _addFromUrl,
            isFullWidth: true,
          ),

          const SizedBox(height: AppSpacing.lg),

          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  'or',
                  style: AppFonts.inter(
                    fontSize: 13,
                    color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          AppButton(
            label: 'Upload Image',
            icon: Icons.upload_file,
            variant: AppButtonVariant.secondary,
            isLoading: _uploading,
            onPressed: _uploading ? null : _uploadImage,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}
