import '../../../core/errors/error_handler.dart';
import '../../../core/services/supabase_service.dart';
import '../../brand_changelog/data/changelog_repository.dart';
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

      final result = BrandColorModel.fromJson(response);
      try { await ChangelogRepository().addEntry(brandId: brandId, action: 'added', entityType: 'color', entityLabel: label ?? hex); } catch (_) {}
      return result;
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

      final result = BrandColorModel.fromJson(response);
      try { await ChangelogRepository().addEntry(brandId: result.brandId, action: 'updated', entityType: 'color', entityLabel: result.label ?? result.hex); } catch (_) {}
      return result;
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<void> deleteColor(String id) async {
    try {
      final row = await SupabaseService.client
          .from('brand_colors')
          .select('brand_id, label, hex')
          .eq('id', id)
          .maybeSingle();

      await SupabaseService.client
          .from('brand_colors')
          .delete()
          .eq('id', id);

      if (row != null) {
        try { await ChangelogRepository().addEntry(brandId: row['brand_id'] as String, action: 'deleted', entityType: 'color', entityLabel: (row['label'] as String?) ?? (row['hex'] as String)); } catch (_) {}
      }
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
