import '../../../core/errors/error_handler.dart';
import '../../../core/services/supabase_service.dart';
import '../models/brand_font_model.dart';

class FontsRepository {
  FontsRepository();

  Future<List<BrandFontModel>> getBrandFonts(String brandId) async {
    try {
      final response = await SupabaseService.client
          .from('brand_fonts')
          .select()
          .eq('brand_id', brandId)
          .order('sort_order');

      return (response as List)
          .map((json) =>
              BrandFontModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<BrandFontModel> addFont({
    required String brandId,
    required String family,
    String? label,
    String? weight,
    String? source,
    String? url,
  }) async {
    try {
      final response = await SupabaseService.client
          .from('brand_fonts')
          .insert({
            'brand_id': brandId,
            'family': family,
            'label': label,
            'weight': weight,
            'source': source,
            if (url != null) 'url': url,
          })
          .select()
          .single();

      return BrandFontModel.fromJson(response);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<BrandFontModel> updateFont(
    String id, {
    String? family,
    String? label,
    String? weight,
    String? source,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (family != null) updates['family'] = family;
      if (label != null) updates['label'] = label;
      if (weight != null) updates['weight'] = weight;
      if (source != null) updates['source'] = source;

      final response = await SupabaseService.client
          .from('brand_fonts')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return BrandFontModel.fromJson(response);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<void> deleteFont(String id) async {
    try {
      await SupabaseService.client
          .from('brand_fonts')
          .delete()
          .eq('id', id);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }
}
