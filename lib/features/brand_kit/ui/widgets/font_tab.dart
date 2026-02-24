import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../core/providers/app_providers.dart';
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
        onSave: (family, label, weight, source) async {
          final brandId = ref.read(currentBrandProvider);
          if (brandId == null) return;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    TextStyle familyStyle;
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
                        widget.font.source ?? 'Google Fonts',
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
    String? source,
  ) onSave;

  @override
  State<_FontDialog> createState() => _FontDialogState();
}

class _FontDialogState extends State<_FontDialog> {
  late final TextEditingController _familyController;
  String? _selectedLabel;
  String? _selectedWeight;
  bool _saving = false;

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
  }

  @override
  void dispose() {
    _familyController.dispose();
    super.dispose();
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
    try {
      final weight = _selectedWeight != null
          ? FontWeight.values[(_weights.indexOf(_selectedWeight!) * 100 ~/ 100)
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
          const SizedBox(height: AppSpacing.lg),
          // Font family with autocomplete
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
              // Sync our controller with autocomplete's controller
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
            onPressed: _familyController.text.trim().isEmpty || _saving
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
        _familyController.text.trim(),
        _selectedLabel,
        _selectedWeight,
        'google',
      );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
