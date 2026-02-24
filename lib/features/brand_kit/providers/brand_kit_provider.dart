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

  final response = await SupabaseService.client
      .from('assets')
      .select()
      .eq('brand_id', brandId)
      .eq('file_type', 'logo');

  return List<Map<String, dynamic>>.from(response as List);
});
