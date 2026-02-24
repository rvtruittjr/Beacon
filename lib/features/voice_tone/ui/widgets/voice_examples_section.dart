import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/design_tokens.dart';
import '../../../../core/config/app_fonts.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/platform_adaptive/adaptive_dialog.dart';
import '../../models/voice_model.dart';
import '../../providers/voice_provider.dart';

class VoiceExamplesSection extends ConsumerWidget {
  const VoiceExamplesSection({super.key});

  static const _platforms = [
    'All',
    'YouTube',
    'TikTok',
    'Instagram',
    'Newsletter',
    'Other',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examplesAsync = ref.watch(voiceExamplesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Voice Examples',
              style: AppFonts.clashDisplay(fontSize: 24, color: textColor),
            ),
            const Spacer(),
            AppButton(
              label: 'Add Example',
              icon: Icons.add,
              onPressed: () => _showExampleDialog(context, ref),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        DefaultTabController(
          length: _platforms.length,
          child: Column(
            children: [
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: textColor,
                unselectedLabelColor: mutedColor,
                indicatorColor: AppColors.blockLime,
                indicatorWeight: 3,
                tabs: _platforms
                    .map((p) => Tab(text: p))
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.md),
              examplesAsync.when(
                loading: () => const SizedBox(
                  height: 100,
                  child: LoadingIndicator(),
                ),
                error: (_, __) =>
                    const Text('Failed to load examples'),
                data: (examples) {
                  if (examples.isEmpty) {
                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: Text(
                        'No voice examples yet. Add one to get started.',
                        style: AppFonts.inter(
                                fontSize: 14, color: mutedColor)
                            .copyWith(fontStyle: FontStyle.italic),
                      ),
                    );
                  }

                  // For simplicity, show all examples for now
                  // (tab filtering handled via builder)
                  return SizedBox(
                    height: 400,
                    child: TabBarView(
                      children: _platforms.map((platform) {
                        final filtered = platform == 'All'
                            ? examples
                            : examples
                                .where((e) =>
                                    e.platform?.toLowerCase() ==
                                    platform.toLowerCase())
                                .toList();

                        if (filtered.isEmpty) {
                          return Center(
                            child: Text(
                              'No $platform examples yet.',
                              style: AppFonts.inter(
                                      fontSize: 14, color: mutedColor)
                                  .copyWith(fontStyle: FontStyle.italic),
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) =>
                              _VoiceExampleCard(
                            example: filtered[index],
                            onEdit: () => _showExampleDialog(
                                context, ref,
                                existing: filtered[index]),
                            onDelete: () async {
                              if (filtered[index].id != null) {
                                await ref
                                    .read(voiceRepositoryProvider)
                                    .deleteVoiceExample(
                                        filtered[index].id!);
                                ref.invalidate(voiceExamplesProvider);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showExampleDialog(
    BuildContext context,
    WidgetRef ref, {
    VoiceExampleModel? existing,
  }) {
    AdaptiveDialog.show(
      context: context,
      child: _ExampleDialog(
        existing: existing,
        onSave: (platform, type, content, notes) async {
          final brandId = ref.read(currentBrandProvider);
          if (brandId == null) return;

          final example = VoiceExampleModel(
            brandId: brandId,
            platform: platform,
            type: type,
            content: content,
            notes: notes,
          );

          if (existing?.id != null) {
            await ref
                .read(voiceRepositoryProvider)
                .updateVoiceExample(existing!.id!, example);
          } else {
            await ref
                .read(voiceRepositoryProvider)
                .addVoiceExample(example);
          }
          ref.invalidate(voiceExamplesProvider);
        },
      ),
    );
  }
}

// ─── Example card ───────────────────────────────────────────────

class _VoiceExampleCard extends StatefulWidget {
  const _VoiceExampleCard({
    required this.example,
    required this.onEdit,
    required this.onDelete,
  });

  final VoiceExampleModel example;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_VoiceExampleCard> createState() => _VoiceExampleCardState();
}

class _VoiceExampleCardState extends State<_VoiceExampleCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.all(AppRadius.lg),
        boxShadow: isDark ? null : AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              if (widget.example.platform != null)
                AppBadge(
                  label: widget.example.platform!,
                  variant: AppBadgeVariant.platform,
                  platformName: widget.example.platform,
                ),
              if (widget.example.type != null) ...[
                const SizedBox(width: 6),
                AppBadge(label: widget.example.type!),
              ],
              const Spacer(),
              IconButton(
                icon: Icon(Icons.edit_outlined,
                    size: 16, color: mutedColor),
                onPressed: widget.onEdit,
                constraints: const BoxConstraints(
                    minWidth: 28, minHeight: 28),
                padding: EdgeInsets.zero,
              ),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    size: 16, color: mutedColor),
                onPressed: widget.onDelete,
                constraints: const BoxConstraints(
                    minWidth: 28, minHeight: 28),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Quote block
          Container(
            padding: const EdgeInsets.only(left: AppSpacing.md),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: AppColors.blockLime,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              widget.example.content,
              style: AppFonts.inter(fontSize: 14, color: textColor)
                  .copyWith(fontStyle: FontStyle.italic),
            ),
          ),
          // "Why this works" expandable
          if (widget.example.notes != null &&
              widget.example.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  Icon(
                    _expanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 18,
                    color: mutedColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Why this works',
                    style: AppFonts.inter(
                        fontSize: 12, color: mutedColor),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  widget.example.notes!,
                  style: AppFonts.inter(
                      fontSize: 13, color: mutedColor),
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Add/edit example dialog ────────────────────────────────────

class _ExampleDialog extends StatefulWidget {
  const _ExampleDialog({this.existing, required this.onSave});

  final VoiceExampleModel? existing;
  final Future<void> Function(
    String? platform,
    String? type,
    String content,
    String? notes,
  ) onSave;

  @override
  State<_ExampleDialog> createState() => _ExampleDialogState();
}

class _ExampleDialogState extends State<_ExampleDialog> {
  String? _platform;
  String? _type;
  late final TextEditingController _contentController;
  late final TextEditingController _notesController;
  bool _saving = false;

  static const _platforms = [
    'YouTube',
    'TikTok',
    'Instagram',
    'Newsletter',
    'Other',
  ];
  static const _types = [
    'caption',
    'hook',
    'email',
    'script',
    'tweet',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _platform = widget.existing?.platform;
    _type = widget.existing?.type;
    _contentController =
        TextEditingController(text: widget.existing?.content ?? '');
    _notesController =
        TextEditingController(text: widget.existing?.notes ?? '');
  }

  @override
  void dispose() {
    _contentController.dispose();
    _notesController.dispose();
    super.dispose();
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
            widget.existing != null ? 'Edit Example' : 'Add Example',
            style: AppFonts.clashDisplay(fontSize: 24, color: textColor),
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String>(
            value: _platform,
            decoration: const InputDecoration(labelText: 'Platform'),
            items: _platforms
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (v) => setState(() => _platform = v),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            value: _type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: _types
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _type = v),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _contentController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Content',
              hintText: 'Paste your voice example here…',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Why this works (optional)',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Save',
            isLoading: _saving,
            onPressed: _contentController.text.trim().isEmpty || _saving
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
        _platform,
        _type,
        _contentController.text.trim(),
        _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
