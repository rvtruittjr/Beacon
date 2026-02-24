import '../../../core/errors/error_handler.dart';
import '../../../core/services/supabase_service.dart';
import '../models/voice_model.dart';

class VoiceRepository {
  VoiceRepository();

  Future<VoiceModel?> getVoice(String brandId) async {
    try {
      final response = await SupabaseService.client
          .from('brand_voice')
          .select()
          .eq('brand_id', brandId)
          .maybeSingle();

      if (response == null) return null;
      return VoiceModel.fromJson(response);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<VoiceModel> upsertVoice(String brandId, VoiceModel voice) async {
    try {
      final data = voice.toJson();
      data['brand_id'] = brandId;

      final response = await SupabaseService.client
          .from('brand_voice')
          .upsert(data, onConflict: 'brand_id')
          .select()
          .single();

      return VoiceModel.fromJson(response);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<List<VoiceExampleModel>> getVoiceExamples(String brandId) async {
    try {
      final response = await SupabaseService.client
          .from('brand_voice_examples')
          .select()
          .eq('brand_id', brandId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) =>
              VoiceExampleModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<VoiceExampleModel> addVoiceExample(VoiceExampleModel example) async {
    try {
      final response = await SupabaseService.client
          .from('brand_voice_examples')
          .insert(example.toJson())
          .select()
          .single();

      return VoiceExampleModel.fromJson(response);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<VoiceExampleModel> updateVoiceExample(
    String id,
    VoiceExampleModel example,
  ) async {
    try {
      final response = await SupabaseService.client
          .from('brand_voice_examples')
          .update(example.toJson())
          .eq('id', id)
          .select()
          .single();

      return VoiceExampleModel.fromJson(response);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<void> deleteVoiceExample(String id) async {
    try {
      await SupabaseService.client
          .from('brand_voice_examples')
          .delete()
          .eq('id', id);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }
}
