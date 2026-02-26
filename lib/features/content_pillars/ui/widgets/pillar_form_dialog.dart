import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/upgrade_sheet.dart';
import '../../data/content_pillar_repository.dart';
import '../../models/content_pillar_model.dart';
import '../../providers/content_pillar_provider.dart';
import '../../../brand_snapshot/providers/snapshot_provider.dart';
import '../../../content_archive/providers/archive_provider.dart';

class PillarFormDialog extends ConsumerStatefulWidget {
  const PillarFormDialog({super.key, this.existing});
  final ContentPillarModel? existing;

  @override
  ConsumerState<PillarFormDialog> createState() => _PillarFormDialogState();
}

class _PillarFormDialogState extends ConsumerState<PillarFormDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late String _selectedColor;
  bool _saving = false;
  String? _error;

  static const _presetColors = [
    '#6C63FF', // violet
    '#FF6B6B', // coral
    '#C8F135', // lime
    '#FFD166', // yellow
    '#22C55E', // green
    '#F59E0B', // amber
    '#EC4899', // pink
    '#8B5CF6', // purple
    '#06B6D4', // cyan
    '#F97316', // orange
    '#14B8A6', // teal
    '#64748B', // slate
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _selectedColor = e?.color ?? _presetColors.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

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
              widget.existing != null ? 'Edit Pillar' : 'Add Pillar',
              style: AppFonts.clashDisplay(fontSize: 24, color: textColor),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Name
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Name *'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),

            // Description
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'What kind of content falls under this pillar?',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Color picker
            Text(
              'COLOR',
              style: AppFonts.inter(fontSize: 11, color: mutedColor)
                  .copyWith(fontWeight: FontWeight.w600, letterSpacing: 1),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _presetColors.map((hex) {
                final color = _parseHex(hex);
                final isSelected = hex == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: isDark ? Colors.white : Colors.black,
                              width: 2,
                            )
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            LucideIcons.check,
                            size: 16,
                            color: color.computeLuminance() > 0.5
                                ? const Color(0xFF1A1A1A)
                                : Colors.white,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            if (_error != null) ...[
              Text(
                _error!,
                style: TextStyle(color: AppColors.error, fontSize: 13),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],

            AppButton(
              label: widget.existing != null ? 'Save' : 'Add',
              isLoading: _saving,
              onPressed:
                  _nameCtrl.text.trim().isEmpty || _saving ? null : _save,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final brandId = ref.read(currentBrandProvider);
      if (brandId == null) return;

      final pillar = ContentPillarModel(
        brandId: brandId,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        color: _selectedColor,
        sortOrder: widget.existing?.sortOrder ?? 0,
      );

      final repo = ref.read(contentPillarRepositoryProvider);

      if (widget.existing?.id != null) {
        await repo.updatePillar(widget.existing!.id!, pillar);
      } else {
        await repo.addPillar(pillar);
      }

      ref.invalidate(contentPillarsListProvider);
      ref.invalidate(snapshotProvider);
      ref.invalidate(archivePillarsProvider);
      if (mounted) Navigator.of(context).pop();
    } on UpgradeRequiredException {
      if (mounted) {
        Navigator.of(context).pop();
        showUpgradeSheet(
          context,
          feature: 'Unlimited Pillars',
          description:
              'Your free plan allows up to 5 content pillars. Upgrade to Pro for unlimited.',
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  static Color _parseHex(String hex) {
    final clean = hex.replaceFirst('#', '');
    if (clean.length == 6 && RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(clean)) {
      return Color(int.parse('FF$clean', radix: 16));
    }
    return const Color(0xFF6C63FF);
  }
}
