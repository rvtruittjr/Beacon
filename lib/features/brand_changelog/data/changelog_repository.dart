import '../../../core/services/supabase_service.dart';
import '../models/changelog_entry_model.dart';

class ChangelogRepository {
  ChangelogRepository();

  Future<List<ChangelogEntryModel>> getEntries(
    String brandId, {
    int limit = 50,
  }) async {
    final response = await SupabaseService.client
        .from('brand_changelog')
        .select()
        .eq('brand_id', brandId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((json) =>
            ChangelogEntryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addEntry({
    required String brandId,
    required String action,
    required String entityType,
    String? entityLabel,
    Map<String, dynamic>? details,
  }) async {
    await SupabaseService.client.from('brand_changelog').insert({
      'brand_id': brandId,
      'action': action,
      'entity_type': entityType,
      'entity_label': entityLabel,
      'details': details,
    });
  }
}
