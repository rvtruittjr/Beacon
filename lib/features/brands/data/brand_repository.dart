import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/services/supabase_service.dart';
import '../models/brand_model.dart';

class BrandRepository {
  BrandRepository();

  Future<List<BrandModel>> getUserBrands(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('brands')
          .select()
          .eq('user_id', userId)
          .order('created_at');

      return (response as List)
          .map((json) => BrandModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<BrandModel> getBrandById(String id) async {
    try {
      final response = await SupabaseService.client
          .from('brands')
          .select()
          .eq('id', id)
          .single();

      return BrandModel.fromJson(response);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<BrandModel> createBrand({
    required String name,
    String? description,
  }) async {
    try {
      final client = SupabaseService.client;
      final user = client.auth.currentUser;
      if (user == null) {
        throw const AuthException('You must be signed in to create a brand.');
      }

      // Free tier enforcement
      final sub = await client
          .from('subscriptions')
          .select('plan')
          .eq('user_id', user.id)
          .maybeSingle();

      final plan = sub?['plan'] as String? ?? 'free';

      if (plan == 'free') {
        final existing = await client
            .from('brands')
            .select('id')
            .eq('user_id', user.id);

        if ((existing as List).isNotEmpty) {
          throw const UpgradeRequiredException(
            'Free plan is limited to 1 brand',
            feature: 'multiple_brands',
          );
        }
      }

      final response = await client.from('brands').insert({
        'user_id': user.id,
        'name': name,
        'description': description,
      }).select().single();

      return BrandModel.fromJson(response);
    } catch (e, stack) {
      if (e is AppException) rethrow;
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<BrandModel> updateBrand(
    String id, {
    String? name,
    String? description,
    bool? onboardingComplete,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (onboardingComplete != null) {
        updates['onboarding_complete'] = onboardingComplete;
      }

      final response = await SupabaseService.client
          .from('brands')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return BrandModel.fromJson(response);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<void> deleteBrand(String id) async {
    try {
      await SupabaseService.client.from('brands').delete().eq('id', id);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }
}
