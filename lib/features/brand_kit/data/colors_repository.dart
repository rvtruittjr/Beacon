import '../../../core/errors/error_handler.dart';
import '../../../core/services/supabase_service.dart';
import '../models/brand_color_model.dart';

class ColorsRepository {
  ColorsRepository();

  Future<List<BrandColorModel>> getBrandColors(String brandId) async {
    try {
      final response = await SupabaseService.client
          .from('brand_colors')
          .select()
          .eq('brand_id', brandId)
          .order('sort_order');

      return (response as List)
          .map((json) =>
              BrandColorModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<BrandColorModel> addColor({
    required String brandId,
    required String hex,
    String? label,
  }) async {
    try {
      final response = await SupabaseService.client
          .from('brand_colors')
          .insert({
            'brand_id': brandId,
            'hex': hex,
            'label': label,
          })
          .select()
          .single();

      return BrandColorModel.fromJson(response);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<BrandColorModel> updateColor(
    String id, {
    String? hex,
    String? label,
    int? sortOrder,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (hex != null) updates['hex'] = hex;
      if (label != null) updates['label'] = label;
      if (sortOrder != null) updates['sort_order'] = sortOrder;

      final response = await SupabaseService.client
          .from('brand_colors')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return BrandColorModel.fromJson(response);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<void> deleteColor(String id) async {
    try {
      await SupabaseService.client
          .from('brand_colors')
          .delete()
          .eq('id', id);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<void> reorderColors(List<String> orderedIds) async {
    try {
      for (int i = 0; i < orderedIds.length; i++) {
        await SupabaseService.client
            .from('brand_colors')
            .update({'sort_order': i})
            .eq('id', orderedIds[i]);
      }
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }
}
