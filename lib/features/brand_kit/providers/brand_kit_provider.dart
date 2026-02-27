import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/services/supabase_service.dart';
import '../data/colors_repository.dart';
import '../data/fonts_repository.dart';
import '../models/brand_color_model.dart';
import '../models/brand_font_model.dart';

final colorsRepositoryProvider = Provider<ColorsRepository>((ref) {
  return ColorsRepository();
});

final fontsRepositoryProvider = Provider<FontsRepository>((ref) {
  return FontsRepository();
});

final brandColorsProvider =
    FutureProvider.autoDispose<List<BrandColorModel>>((ref) async {
  final brandId = ref.watch(currentBrandProvider);
  if (brandId == null) return [];

  return ref.watch(colorsRepositoryProvider).getBrandColors(brandId);
});

final brandFontsProvider =
    FutureProvider.autoDispose<List<BrandFontModel>>((ref) async {
  final brandId = ref.watch(currentBrandProvider);
  if (brandId == null) return [];

  return ref.watch(fontsRepositoryProvider).getBrandFonts(brandId);
});

final brandLogosProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final brandId = ref.watch(currentBrandProvider);
  if (brandId == null) return [];

  final client = SupabaseService.client;
  final response = await client
      .from('assets')
      .select()
      .eq('brand_id', brandId)
      .eq('file_type', 'logo');

  final logos = List<Map<String, dynamic>>.from(response as List);

  // The brand-assets bucket is private, so public URLs don't work.
  // Generate signed URLs for each logo so they can be displayed.
  return _withSignedUrls(logos, client);
});

/// Extract storage path from a public URL and create signed URLs for display.
Future<List<Map<String, dynamic>>> _withSignedUrls(
  List<Map<String, dynamic>> items,
  dynamic client, {
  String bucket = 'brand-assets',
}) async {
  const marker = '/object/public/brand-assets/';

  // Collect paths to sign
  final paths = <String>[];
  final pathIndices = <int>[]; // which items need signed URLs

  for (int i = 0; i < items.length; i++) {
    final url = items[i]['file_url'] as String? ?? '';
    final idx = url.indexOf(marker);
    if (idx != -1) {
      paths.add(url.substring(idx + marker.length).split('?').first);
      pathIndices.add(i);
    }
  }

  if (paths.isEmpty) return items;

  // Batch-sign all paths in one API call
  final signed = await SupabaseService.client.storage
      .from(bucket)
      .createSignedUrls(paths, 3600); // 1 hour

  final result = items.map((m) => Map<String, dynamic>.from(m)).toList();
  for (int i = 0; i < signed.length; i++) {
    final signedUrl = signed[i].signedUrl;
    if (signedUrl.isNotEmpty && i < pathIndices.length) {
      result[pathIndices[i]]['file_url'] = signedUrl;
    }
  }

  return result;
}
