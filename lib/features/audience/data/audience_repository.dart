import '../../../core/errors/error_handler.dart';
import '../../../core/services/supabase_service.dart';
import '../models/audience_model.dart';

class AudienceRepository {
  AudienceRepository();

  Future<AudienceModel?> getAudience(String brandId) async {
    try {
      final response = await SupabaseService.client
          .from('brand_audience')
          .select()
          .eq('brand_id', brandId)
          .maybeSingle();

      if (response == null) return null;
      return AudienceModel.fromJson(response);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<AudienceModel> upsertAudience(
    String brandId,
    AudienceModel audience,
  ) async {
    try {
      final data = audience.toJson();
      data['brand_id'] = brandId;

      final response = await SupabaseService.client
          .from('brand_audience')
          .upsert(data, onConflict: 'brand_id')
          .select()
          .single();

      return AudienceModel.fromJson(response);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }
}
