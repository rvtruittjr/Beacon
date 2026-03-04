// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/design_tokens.dart';
import '../../../core/config/app_fonts.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/empty_state.dart';
import '../models/platform_preset.dart';
import '../providers/social_kit_provider.dart';
import '../services/social_kit_export_service.dart';
import 'widgets/platform_card.dart';

class SocialMediaKitScreen extends ConsumerStatefulWidget {
  const SocialMediaKitScreen({super.key});

  @override
  ConsumerState<SocialMediaKitScreen> createState() =>
      _SocialMediaKitScreenState();
}

class _SocialMediaKitScreenState
    extends ConsumerState<SocialMediaKitScreen> {
  final Set<String> _generating = {};
  bool _downloadingAll = false;

  Future<void> _downloadSingle(
    PlatformPreset preset,
    SocialKitData data,
  ) async {
    final key = '${preset.platform}_${preset.variant}';
    setState(() => _generating.add(key));

    try {
      final bytes = await SocialKitExportService.generateSingle(
        preset: preset,
        brandName: data.brandName,
        primaryColorHex: data.primaryColorHex,
        logoUrl: data.logoUrl,
      );
      if (bytes == null) return;

      final blob = html.Blob([bytes], 'image/png');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', preset.fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } finally {
      if (mounted) setState(() => _generating.remove(key));
    }
  }

  Future<void> _downloadAll(SocialKitData data) async {
    setState(() => _downloadingAll = true);

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generating social media kit…'),
          duration: Duration(seconds: 10),
          behavior: SnackBarBehavior.floating,
          width: 280,
        ),
      );

      final zipBytes = await SocialKitExportService.generateZip(
        brandName: data.brandName,
        primaryColorHex: data.primaryColorHex,
        logoUrl: data.logoUrl,
      );

      ScaffoldMessenger.of(context).clearSnackBars();

      final blob = html.Blob([zipBytes], 'application/zip');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', '${data.brandName}_social_kit.zip')
        ..click();
      html.Url.revokeObjectUrl(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Social media kit downloaded!'),
            behavior: SnackBarBehavior.floating,
            width: 280,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate kit'),
            behavior: SnackBarBehavior.floating,
            width: 280,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _downloadingAll = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    final dataAsync = ref.watch(socialKitDataProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0,
          ),
          child: Row(
            children: [
              Text(
                'Social Media Kit',
                style: AppFonts.clashDisplay(fontSize: 32, color: textColor),
              ),
              const Spacer(),
              dataAsync.whenOrNull(
                    data: (data) {
                      if (data == null) return const SizedBox.shrink();
                      return AppButton(
                        label: 'Download All',
                        icon: Icons.download,
                        isLoading: _downloadingAll,
                        onPressed:
                            _downloadingAll ? null : () => _downloadAll(data),
                      );
                    },
                  ) ??
                  const SizedBox.shrink(),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: dataAsync.when(
            loading: () => const LoadingIndicator(),
            error: (_, __) =>
                const Center(child: Text('Failed to load brand data')),
            data: (data) {
              if (data == null) {
                return EmptyState(
                  blockColor: AppColors.blockViolet,
                  icon: Icons.share_outlined,
                  headline: 'No brand selected',
                  supportingText: 'Select a brand to generate social images.',
                );
              }

              final grouped = PlatformPreset.grouped;

              return ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                children: grouped.entries.map((entry) {
                  return _PlatformSection(
                    platform: entry.key,
                    presets: entry.value,
                    data: data,
                    generating: _generating,
                    onDownload: (preset) => _downloadSingle(preset, data),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PlatformSection extends StatelessWidget {
  const _PlatformSection({
    required this.platform,
    required this.presets,
    required this.data,
    required this.generating,
    required this.onDownload,
  });

  final String platform;
  final List<PlatformPreset> presets;
  final SocialKitData data;
  final Set<String> generating;
  final void Function(PlatformPreset) onDownload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(presets.first.icon, size: 20, color: textColor),
              const SizedBox(width: AppSpacing.sm),
              Text(
                platform,
                style: AppFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth > 700
                  ? 3
                  : constraints.maxWidth > 400
                      ? 2
                      : 1;

              return Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: presets.map((preset) {
                  final key = '${preset.platform}_${preset.variant}';
                  final cardWidth =
                      (constraints.maxWidth - (cols - 1) * AppSpacing.md) /
                          cols;
                  return SizedBox(
                    width: cardWidth,
                    child: PlatformCard(
                      preset: preset,
                      isGenerating: generating.contains(key),
                      onDownload: () => onDownload(preset),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
