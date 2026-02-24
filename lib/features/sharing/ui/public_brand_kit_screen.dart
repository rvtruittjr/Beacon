import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/design_tokens.dart';
import '../../../core/config/app_fonts.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../brands/models/brand_model.dart';
import '../../brand_snapshot/providers/snapshot_provider.dart';
import '../../brand_snapshot/ui/widgets/snapshot_header.dart';
import '../../brand_snapshot/ui/widgets/color_palette_section.dart';
import '../../brand_snapshot/ui/widgets/typography_section.dart';
import '../../brand_snapshot/ui/widgets/logo_variations_section.dart';
import '../../brand_snapshot/ui/widgets/brand_voice_section.dart';
import '../../brand_snapshot/ui/widgets/audience_section.dart';
import '../../brand_snapshot/ui/widgets/content_pillars_section.dart';
import '../data/share_repository.dart';

/// Provider to load public brand data by share token.
final _publicBrandProvider =
    FutureProvider.autoDispose.family<_PublicBrandData?, String>(
        (ref, token) async {
  final repo = ref.watch(shareRepositoryProvider);
  final brand = await repo.getBrandByShareToken(token);
  if (brand == null) return null;

  // Check access conditions
  if (!brand.isPublic) return _PublicBrandData.error('This brand kit is private.');
  if (brand.shareExpiresAt != null &&
      brand.shareExpiresAt!.isBefore(DateTime.now())) {
    return _PublicBrandData.error('This link has expired.');
  }

  // Check if password protected
  if (brand.sharePasswordHash != null) {
    return _PublicBrandData.passwordRequired(brand);
  }

  // Load snapshot data
  final client = SupabaseService.client;

  Future<T> safeQuery<T>(Future<T> query, T fallback) async {
    try {
      return await query;
    } catch (_) {
      return fallback;
    }
  }

  final results = await Future.wait<dynamic>([
    safeQuery(
      client.from('brand_colors').select().eq('brand_id', brand.id).order('sort_order'),
      <dynamic>[],
    ),
    safeQuery(
      client.from('brand_fonts').select().eq('brand_id', brand.id).order('sort_order'),
      <dynamic>[],
    ),
    safeQuery(
      client.from('brand_voice').select().eq('brand_id', brand.id).maybeSingle(),
      null,
    ),
    safeQuery(
      client.from('brand_audience').select().eq('brand_id', brand.id).maybeSingle(),
      null,
    ),
    safeQuery(
      client.from('content_pillars').select().eq('brand_id', brand.id).order('sort_order'),
      <dynamic>[],
    ),
    safeQuery(
      client.from('assets').select().eq('brand_id', brand.id).eq('file_type', 'logo'),
      <dynamic>[],
    ),
  ]);

  return _PublicBrandData.loaded(
    brand: brand,
    colors: List<Map<String, dynamic>>.from(results[0] as List),
    fonts: List<Map<String, dynamic>>.from(results[1] as List),
    voice: results[2] as Map<String, dynamic>?,
    audience: results[3] as Map<String, dynamic>?,
    pillars: List<Map<String, dynamic>>.from(results[4] as List),
    logos: List<Map<String, dynamic>>.from(results[5] as List),
  );
});

class _PublicBrandData {
  final BrandModel? brand;
  final String? errorMessage;
  final bool needsPassword;
  final List<Map<String, dynamic>> colors;
  final List<Map<String, dynamic>> fonts;
  final Map<String, dynamic>? voice;
  final Map<String, dynamic>? audience;
  final List<Map<String, dynamic>> pillars;
  final List<Map<String, dynamic>> logos;

  const _PublicBrandData({
    this.brand,
    this.errorMessage,
    this.needsPassword = false,
    this.colors = const [],
    this.fonts = const [],
    this.voice,
    this.audience,
    this.pillars = const [],
    this.logos = const [],
  });

  factory _PublicBrandData.error(String msg) =>
      _PublicBrandData(errorMessage: msg);

  factory _PublicBrandData.passwordRequired(BrandModel brand) =>
      _PublicBrandData(brand: brand, needsPassword: true);

  factory _PublicBrandData.loaded({
    required BrandModel brand,
    required List<Map<String, dynamic>> colors,
    required List<Map<String, dynamic>> fonts,
    Map<String, dynamic>? voice,
    Map<String, dynamic>? audience,
    required List<Map<String, dynamic>> pillars,
    required List<Map<String, dynamic>> logos,
  }) =>
      _PublicBrandData(
        brand: brand,
        colors: colors,
        fonts: fonts,
        voice: voice,
        audience: audience,
        pillars: pillars,
        logos: logos,
      );
}

class PublicBrandKitScreen extends ConsumerWidget {
  const PublicBrandKitScreen({super.key, required this.shareToken});
  final String shareToken;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(_publicBrandProvider(shareToken));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Scaffold(
      body: dataAsync.when(
        loading: () => const LoadingIndicator(caption: 'Loading brand kit…'),
        error: (_, __) => _ErrorView(
          message:
              "This brand kit doesn't exist or the link has been reset.",
        ),
        data: (data) {
          if (data == null) {
            return _ErrorView(
              message:
                  "This brand kit doesn't exist or the link has been reset.",
            );
          }
          if (data.errorMessage != null) {
            return _ErrorView(message: data.errorMessage!);
          }
          if (data.needsPassword) {
            // Redirect to password gate handled by router
            return _ErrorView(message: 'Password required.');
          }

          final brand = data.brand!;
          final expiryWarning = brand.shareExpiresAt != null &&
              brand.shareExpiresAt!
                  .difference(DateTime.now())
                  .inHours <
                  48;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.x2l,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand name
                    Text(
                      brand.name,
                      style:
                          AppFonts.clashDisplay(fontSize: 48, color: textColor),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Expiry warning
                    if (expiryWarning)
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        margin:
                            const EdgeInsets.only(bottom: AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.all(AppRadius.md),
                        ),
                        child: Text(
                          'This link expires ${_formatDate(brand.shareExpiresAt!)}.',
                          style: const TextStyle(
                            color: AppColors.warning,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    // Sections
                    ColorPaletteSection(colors: data.colors),
                    const SizedBox(height: AppSpacing.lg),
                    TypographySection(fonts: data.fonts),
                    const SizedBox(height: AppSpacing.lg),
                    LogoVariationsSection(logos: data.logos),
                    const SizedBox(height: AppSpacing.lg),
                    BrandVoiceSection(voice: data.voice),
                    const SizedBox(height: AppSpacing.lg),
                    AudienceSection(audience: data.audience),
                    const SizedBox(height: AppSpacing.lg),
                    ContentPillarsSection(pillars: data.pillars),
                    const SizedBox(height: AppSpacing.x2l),

                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Last updated ${_formatDate(brand.createdAt)}',
                          style: TextStyle(fontSize: 12, color: mutedColor),
                        ),
                        Text(
                          'Powered by Beacøn',
                          style: AppFonts.inter(
                            fontSize: 12,
                            color: mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Beacøn',
              style: AppFonts.clashDisplay(
                fontSize: 28,
                color: AppColors.blockYellow,
              ),
            ),
            const SizedBox(height: AppSpacing.x2l),
            Text(
              message,
              style: AppFonts.inter(
                fontSize: 16,
                color: AppColors.mutedLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
