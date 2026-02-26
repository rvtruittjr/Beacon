import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/custom_font_loader.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/platform_adaptive/adaptive_dialog.dart';
import '../../models/brand_font_model.dart';
import '../../providers/brand_kit_provider.dart';

class FontTab extends ConsumerWidget {
  const FontTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontsAsync = ref.watch(brandFontsProvider);

    return fontsAsync.when(
      loading: () => const LoadingIndicator(),
      error: (_, __) => const Center(child: Text('Failed to load fonts')),
      data: (fonts) {
        if (fonts.isEmpty) {
          return EmptyState(
            blockColor: AppColors.blockViolet,
            icon: Icons.text_fields_outlined,
            headline: 'No fonts yet',
            supportingText: 'Add your brand fonts to keep your type consistent.',
            ctaLabel: 'Add first font',
            onCtaPressed: () => _showFontDialog(context, ref),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppButton(
                      label: 'Add font',
                      icon: Icons.add,
                      onPressed: () => _showFontDialog(context, ref),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: ListView.separated(
                      itemCount: fonts.length,
                      separatorBuilder: (_, __) => Divider(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                      itemBuilder: (context, index) {
                        return _FontRow(
                          font: fonts[index],
                          onEdit: () =>
                              _showFontDialog(context, ref, existing: fonts[index]),
                          onDelete: () => _deleteFont(ref, fonts[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFontDialog(
    BuildContext context,
    WidgetRef ref, {
    BrandFontModel? existing,
  }) {
    AdaptiveDialog.show(
      context: context,
      child: _FontDialog(
        existing: existing,
        onSave: (family, label, weight, source, {PlatformFile? file}) async {
          final brandId = ref.read(currentBrandProvider);
          if (brandId == null) return;

          String? fontUrl;
          if (source == 'upload' && file != null) {
            final user = SupabaseService.client.auth.currentUser;
            if (user != null) {
              fontUrl = await StorageService.uploadFont(
                user.id,
                brandId,
                file,
              );
            }
          }

          if (existing != null) {
            await ref.read(fontsRepositoryProvider).updateFont(
                  existing.id,
                  family: family,
                  label: label,
                  weight: weight,
                  source: source,
                );
          } else {
            await ref.read(fontsRepositoryProvider).addFont(
                  brandId: brandId,
                  family: family,
                  label: label,
                  weight: weight,
                  source: source,
                  url: fontUrl,
                );
          }
          ref.invalidate(brandFontsProvider);
        },
      ),
    );
  }

  Future<void> _deleteFont(WidgetRef ref, BrandFontModel font) async {
    await ref.read(fontsRepositoryProvider).deleteFont(font.id);
    ref.invalidate(brandFontsProvider);
  }
}

// ─── Font row ───────────────────────────────────────────────────

class _FontRow extends StatefulWidget {
  const _FontRow({
    required this.font,
    required this.onEdit,
    required this.onDelete,
  });

  final BrandFontModel font;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_FontRow> createState() => _FontRowState();
}

class _FontRowState extends State<_FontRow> {
  bool _isHovered = false;
  bool _fontLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadCustomFont();
  }

  @override
  void didUpdateWidget(covariant _FontRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.font.url != widget.font.url) _loadCustomFont();
  }

  Future<void> _loadCustomFont() async {
    if (widget.font.source != 'upload' || widget.font.url == null) return;
    if (CustomFontLoader.isLoaded(widget.font.family)) {
      _fontLoaded = true;
      return;
    }
    await CustomFontLoader.load(widget.font.family, widget.font.url!);
    if (mounted) setState(() => _fontLoaded = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    TextStyle familyStyle;
    if (widget.font.source == 'upload') {
      familyStyle = TextStyle(
        fontFamily: _fontLoaded ? widget.font.family : null,
        fontSize: 36,
        color: textColor,
      );
    } else {
      try {
        familyStyle = GoogleFonts.getFont(
          widget.font.family,
          fontSize: 36,
          color: textColor,
        );
      } catch (_) {
        familyStyle = TextStyle(
          fontFamily: widget.font.family,
          fontSize: 36,
          color: textColor,
        );
      }
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.font.family, style: familyStyle),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (widget.font.label != null)
                        AppBadge(label: widget.font.label!),
                      if (widget.font.label != null)
                        const SizedBox(width: AppSpacing.sm),
                      Text(
                        widget.font.source == 'upload'
                            ? 'Uploaded'
                            : 'Google Fonts',
                        style:
                            AppFonts.inter(fontSize: 12, color: mutedColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_isHovered) ...[
              IconButton(
                icon: Icon(Icons.edit_outlined, size: 18, color: mutedColor),
                onPressed: widget.onEdit,
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, size: 18, color: mutedColor),
                onPressed: widget.onDelete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Font dialog ────────────────────────────────────────────────

class _FontDialog extends StatefulWidget {
  const _FontDialog({this.existing, required this.onSave});

  final BrandFontModel? existing;
  final Future<void> Function(
    String family,
    String? label,
    String? weight,
    String? source, {
    PlatformFile? file,
  }) onSave;

  @override
  State<_FontDialog> createState() => _FontDialogState();
}

class _FontDialogState extends State<_FontDialog> {
  late final TextEditingController _familyController;
  String? _selectedLabel;
  String? _selectedWeight;
  bool _saving = false;
  bool _isUploadMode = false;
  PlatformFile? _pickedFile;

  static const _labels = ['Heading', 'Body', 'Display', 'Caption', 'Accent'];
  static const _weights = ['400', '500', '600', '700', '800'];

  // Common Google Fonts for autocomplete suggestions
  static const _suggestedFonts = [
    'Inter',
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Poppins',
    'Raleway',
    'Playfair Display',
    'Merriweather',
    'Source Sans Pro',
    'Ubuntu',
    'Nunito',
    'Work Sans',
    'DM Sans',
    'Space Grotesk',
    'Outfit',
    'Sora',
    'Clash Display',
    'Manrope',
    'Archivo',
  ];

  @override
  void initState() {
    super.initState();
    _familyController = TextEditingController(
      text: widget.existing?.family ?? '',
    );
    _selectedLabel = widget.existing?.label;
    _selectedWeight = widget.existing?.weight;
    _isUploadMode = widget.existing?.source == 'upload';
  }

  @override
  void dispose() {
    _familyController.dispose();
    super.dispose();
  }

  Future<void> _pickFontFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['ttf', 'otf', 'woff', 'woff2'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final familyName = file.name
        .replaceAll(RegExp(r'\.(ttf|otf|woff2?)$', caseSensitive: false), '')
        .replaceAll(RegExp(r'[-_]'), ' ')
        .trim();

    // Register font immediately so the preview renders correctly.
    if (file.bytes != null) {
      final loader = FontLoader(familyName);
      loader.addFont(
        Future.value(ByteData.view(file.bytes!.buffer)),
      );
      await loader.load();
    }

    if (!mounted) return;
    setState(() {
      _pickedFile = file;
      _familyController.text = familyName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    // Live preview
    TextStyle previewStyle;
    if (_isUploadMode) {
      previewStyle = TextStyle(
        fontFamily: _familyController.text,
        fontSize: 24,
        color: _pickedFile != null ? textColor : mutedColor,
        fontStyle: _pickedFile != null ? null : FontStyle.italic,
      );
    } else {
      try {
        final weight = _selectedWeight != null
            ? FontWeight
                .values[(_weights.indexOf(_selectedWeight!) * 100 ~/ 100)
                    .clamp(0, FontWeight.values.length - 1)]
            : FontWeight.w400;
        previewStyle = GoogleFonts.getFont(
          _familyController.text,
          fontSize: 24,
          color: textColor,
          fontWeight: weight,
        );
      } catch (_) {
        previewStyle = TextStyle(
          fontSize: 24,
          color: mutedColor,
          fontStyle: FontStyle.italic,
        );
      }
    }

    final bool canSave = _isUploadMode
        ? (_familyController.text.trim().isNotEmpty && _pickedFile != null)
        : _familyController.text.trim().isNotEmpty;

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
            widget.existing != null ? 'Edit Font' : 'Add Font',
            style: AppFonts.clashDisplay(fontSize: 24, color: textColor),
          ),
          const SizedBox(height: AppSpacing.md),
          // Source toggle
          if (widget.existing == null) ...[
            Row(
              children: [
                _SourceToggle(
                  label: 'Google Fonts',
                  isSelected: !_isUploadMode,
                  onTap: () => setState(() {
                    _isUploadMode = false;
                    _pickedFile = null;
                    _familyController.clear();
                  }),
                ),
                const SizedBox(width: AppSpacing.sm),
                _SourceToggle(
                  label: 'Upload',
                  isSelected: _isUploadMode,
                  onTap: () => setState(() {
                    _isUploadMode = true;
                    _familyController.clear();
                  }),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          if (_isUploadMode) ...[
            // Upload mode
            if (_pickedFile != null)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceMidDark
                      : AppColors.surfaceMidLight,
                  borderRadius: BorderRadius.all(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.fileText, size: 18, color: mutedColor),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _pickedFile!.name,
                        style: AppFonts.inter(fontSize: 13, color: textColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() {
                        _pickedFile = null;
                        _familyController.clear();
                      }),
                      icon: Icon(Icons.close, size: 16, color: mutedColor),
                      constraints:
                          const BoxConstraints(minWidth: 28, minHeight: 28),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _pickFontFile,
                icon: const Icon(LucideIcons.upload, size: 16),
                label: const Text('Choose font file'),
              ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Supports .ttf, .otf, .woff, .woff2',
              style: AppFonts.inter(fontSize: 11, color: mutedColor),
            ),
            const SizedBox(height: AppSpacing.md),
            // Font family name
            TextField(
              controller: _familyController,
              decoration: const InputDecoration(
                labelText: 'Font family name',
                hintText: 'e.g. My Custom Font',
              ),
              onChanged: (_) => setState(() {}),
            ),
          ] else ...[
            // Google Fonts mode
            Autocomplete<String>(
              initialValue: _familyController.value,
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) return const [];
                final query = textEditingValue.text.toLowerCase();
                return _suggestedFonts
                    .where((f) => f.toLowerCase().contains(query))
                    .toList();
              },
              onSelected: (value) {
                _familyController.text = value;
                setState(() {});
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                controller.addListener(() {
                  if (_familyController.text != controller.text) {
                    _familyController.text = controller.text;
                    setState(() {});
                  }
                });
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Font family',
                    hintText: 'e.g. Inter, Poppins',
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          // Label dropdown
          DropdownButtonFormField<String>(
            value: _selectedLabel,
            decoration: const InputDecoration(labelText: 'Label'),
            items: _labels
                .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                .toList(),
            onChanged: (v) => setState(() => _selectedLabel = v),
          ),
          const SizedBox(height: AppSpacing.md),
          // Weight dropdown
          DropdownButtonFormField<String>(
            value: _selectedWeight,
            decoration: const InputDecoration(labelText: 'Weight'),
            items: _weights
                .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                .toList(),
            onChanged: (v) => setState(() => _selectedWeight = v),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Live preview
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceMidDark
                  : AppColors.surfaceMidLight,
              borderRadius: BorderRadius.all(AppRadius.md),
            ),
            child: Text('The quick brown fox', style: previewStyle),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: widget.existing != null ? 'Save' : 'Add',
            isLoading: _saving,
            onPressed: !canSave || _saving ? null : _save,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      if (_isUploadMode && _pickedFile != null) {
        await widget.onSave(
          _familyController.text.trim(),
          _selectedLabel,
          _selectedWeight,
          'upload',
          file: _pickedFile,
        );
      } else {
        await widget.onSave(
          _familyController.text.trim(),
          _selectedLabel,
          _selectedWeight,
          'google',
        );
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _SourceToggle extends StatelessWidget {
  const _SourceToggle({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.blockLime
              : (isDark ? AppColors.surfaceMidDark : AppColors.surfaceMidLight),
          borderRadius: BorderRadius.all(AppRadius.full),
        ),
        child: Text(
          label,
          style: AppFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? AppColors.textOnLime
                : (isDark ? AppColors.mutedDark : AppColors.mutedLight),
          ),
        ),
      ),
    );
  }
}
