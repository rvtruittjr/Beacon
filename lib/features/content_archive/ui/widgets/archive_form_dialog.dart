import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/upgrade_sheet.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/archive_repository.dart';
import '../../models/archive_item_model.dart';
import '../../providers/archive_provider.dart';

class ArchiveFormDialog extends ConsumerStatefulWidget {
  const ArchiveFormDialog({super.key, this.existing});
  final ArchiveItemModel? existing;

  @override
  ConsumerState<ArchiveFormDialog> createState() => _ArchiveFormDialogState();
}

class _ArchiveFormDialogState extends ConsumerState<ArchiveFormDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _urlCtrl;
  late final TextEditingController _hookCtrl;
  late final TextEditingController _viewsCtrl;
  late final TextEditingController _likesCtrl;
  late final TextEditingController _commentsCtrl;
  late final TextEditingController _notesCtrl;

  String? _platform;
  String? _pillarId;
  DateTime? _datePosted;
  String? _thumbnailUrl;
  bool _saving = false;
  String? _error;

  static const _platforms = [
    'YouTube',
    'TikTok',
    'Instagram',
    'Twitter/X',
    'Newsletter',
    'Podcast',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _urlCtrl = TextEditingController(text: e?.contentUrl ?? '');
    _hookCtrl = TextEditingController(text: e?.hook ?? '');
    _viewsCtrl = TextEditingController(text: e?.views?.toString() ?? '');
    _likesCtrl = TextEditingController(text: e?.likes?.toString() ?? '');
    _commentsCtrl = TextEditingController(text: e?.comments?.toString() ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _platform = e?.platform;
    _pillarId = e?.pillarId;
    _datePosted = e?.datePosted;
    _thumbnailUrl = e?.thumbnailUrl;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _urlCtrl.dispose();
    _hookCtrl.dispose();
    _viewsCtrl.dispose();
    _likesCtrl.dispose();
    _commentsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final pillarsAsync = ref.watch(archivePillarsProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing != null ? 'Edit Content' : 'Add Content',
              style: AppFonts.clashDisplay(fontSize: 24, color: textColor),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title *'),
            ),
            const SizedBox(height: AppSpacing.md),

            // Platform
            DropdownButtonFormField<String>(
              value: _platform,
              decoration: const InputDecoration(labelText: 'Platform'),
              items: _platforms
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _platform = v),
            ),
            const SizedBox(height: AppSpacing.md),

            // Content URL
            TextField(
              controller: _urlCtrl,
              decoration: const InputDecoration(labelText: 'Content URL'),
            ),
            const SizedBox(height: AppSpacing.md),

            // Thumbnail upload
            Row(
              children: [
                Expanded(
                  child: Text(
                    _thumbnailUrl != null ? 'Thumbnail uploaded' : 'No thumbnail',
                    style: TextStyle(color: mutedColor, fontSize: 13),
                  ),
                ),
                TextButton.icon(
                  onPressed: _uploadThumbnail,
                  icon: const Icon(LucideIcons.upload, size: 16),
                  label: const Text('Upload'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Hook
            TextField(
              controller: _hookCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Hook',
                hintText: 'What was the opening hook?',
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Engagement stats row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _viewsCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Views'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _likesCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Likes'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _commentsCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Comments'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Date posted
            GestureDetector(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date Posted'),
                child: Text(
                  _datePosted != null
                      ? '${_datePosted!.day}/${_datePosted!.month}/${_datePosted!.year}'
                      : 'Select date',
                  style: TextStyle(
                    color: _datePosted != null ? textColor : mutedColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Content Pillar dropdown
            pillarsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (pillars) {
                if (pillars.isEmpty) return const SizedBox.shrink();
                return DropdownButtonFormField<String>(
                  value: _pillarId,
                  decoration:
                      const InputDecoration(labelText: 'Content Pillar'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('None'),
                    ),
                    ...pillars.map((p) => DropdownMenuItem(
                          value: p['id'] as String,
                          child: Text(p['name'] as String? ?? ''),
                        )),
                  ],
                  onChanged: (v) => setState(() => _pillarId = v),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Notes
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'What worked? What would you change?',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            if (_error != null) ...[
              Text(_error!, style: TextStyle(color: AppColors.error, fontSize: 13)),
              const SizedBox(height: AppSpacing.sm),
            ],

            AppButton(
              label: 'Save',
              isLoading: _saving,
              onPressed:
                  _titleCtrl.text.trim().isEmpty || _saving ? null : _save,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _datePosted ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _datePosted = picked);
  }

  Future<void> _uploadThumbnail() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    final client = SupabaseService.client;
    final user = client.auth.currentUser;
    final brandId = ref.read(currentBrandProvider);
    if (user == null || brandId == null) return;

    final path =
        '${user.id}/$brandId/archive/${DateTime.now().millisecondsSinceEpoch}_${file.name}';

    await client.storage.from('brand-assets').uploadBinary(
          path,
          file.bytes!,
          fileOptions: const FileOptions(upsert: true),
        );

    final url = client.storage.from('brand-assets').getPublicUrl(path);
    setState(() => _thumbnailUrl = url);
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final brandId = ref.read(currentBrandProvider);
      if (brandId == null) return;

      final item = ArchiveItemModel(
        brandId: brandId,
        title: _titleCtrl.text.trim(),
        platform: _platform,
        contentUrl:
            _urlCtrl.text.trim().isEmpty ? null : _urlCtrl.text.trim(),
        thumbnailUrl: _thumbnailUrl,
        hook: _hookCtrl.text.trim().isEmpty ? null : _hookCtrl.text.trim(),
        views: int.tryParse(_viewsCtrl.text.trim()),
        likes: int.tryParse(_likesCtrl.text.trim()),
        comments: int.tryParse(_commentsCtrl.text.trim()),
        datePosted: _datePosted,
        pillarId: _pillarId,
        notes:
            _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );

      final repo = ref.read(archiveRepositoryProvider);

      if (widget.existing?.id != null) {
        await repo.updateArchiveItem(widget.existing!.id!, item);
      } else {
        await repo.addArchiveItem(item);
      }

      ref.invalidate(archiveItemsProvider);
      if (mounted) Navigator.of(context).pop();
    } on UpgradeRequiredException catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        showUpgradeSheet(
          context,
          feature: e.feature == 'video_archive'
              ? 'Video Archive'
              : 'Unlimited Archive',
          description: e.feature == 'video_archive'
              ? 'Video archive is a Pro feature. Upgrade to upload videos.'
              : 'Your free archive is full. Upgrade to Pro for unlimited items.',
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
