import '../../../core/services/supabase_service.dart';
import '../models/inspiration_item_model.dart';

class InspirationRepository {
  InspirationRepository();

  Future<List<InspirationItemModel>> getItems(String brandId) async {
    final response = await SupabaseService.client
        .from('inspiration_items')
        .select()
        .eq('brand_id', brandId)
        .order('created_at');

    return (response as List)
        .map((json) =>
            InspirationItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<InspirationItemModel> addItem({
    required String brandId,
    required String imageUrl,
    String? caption,
    double posX = 0,
    double posY = 0,
    double width = 200,
    double height = 200,
  }) async {
    final response = await SupabaseService.client
        .from('inspiration_items')
        .insert({
          'brand_id': brandId,
          'image_url': imageUrl,
          'caption': caption,
          'pos_x': posX,
          'pos_y': posY,
          'width': width,
          'height': height,
        })
        .select()
        .single();

    return InspirationItemModel.fromJson(response);
  }

  Future<void> updatePosition(String id, double posX, double posY) async {
    await SupabaseService.client
        .from('inspiration_items')
        .update({'pos_x': posX, 'pos_y': posY})
        .eq('id', id);
  }

  Future<void> updateSize(String id, double width, double height) async {
    await SupabaseService.client
        .from('inspiration_items')
        .update({'width': width, 'height': height})
        .eq('id', id);
  }

  Future<void> updateCaption(String id, String caption) async {
    await SupabaseService.client
        .from('inspiration_items')
        .update({'caption': caption})
        .eq('id', id);
  }

  Future<void> deleteItem(String id) async {
    await SupabaseService.client
        .from('inspiration_items')
        .delete()
        .eq('id', id);
  }
}
