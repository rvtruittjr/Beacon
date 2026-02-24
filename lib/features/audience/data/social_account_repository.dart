import '../../../core/errors/error_handler.dart';
import '../../../core/services/supabase_service.dart';
import '../models/social_account_model.dart';

class SocialAccountRepository {
  SocialAccountRepository();

  Future<List<SocialAccountModel>> getAccounts(String brandId) async {
    try {
      final response = await SupabaseService.client
          .from('social_accounts')
          .select()
          .eq('brand_id', brandId)
          .order('created_at');

      return (response as List)
          .map((json) =>
              SocialAccountModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<SocialAccountModel> addAccount({
    required String brandId,
    required String platform,
    required String username,
    String? displayName,
    int? followerCount,
    String? profileUrl,
  }) async {
    try {
      final response = await SupabaseService.client
          .from('social_accounts')
          .insert({
            'brand_id': brandId,
            'platform': platform,
            'username': username,
            'display_name': displayName,
            'follower_count': followerCount,
            'profile_url': profileUrl,
          })
          .select()
          .single();

      return SocialAccountModel.fromJson(response);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<SocialAccountModel> updateAccount(
    String id, {
    String? platform,
    String? username,
    String? displayName,
    int? followerCount,
    String? profileUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (platform != null) updates['platform'] = platform;
      if (username != null) updates['username'] = username;
      if (displayName != null) updates['display_name'] = displayName;
      if (followerCount != null) updates['follower_count'] = followerCount;
      if (profileUrl != null) updates['profile_url'] = profileUrl;

      final response = await SupabaseService.client
          .from('social_accounts')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return SocialAccountModel.fromJson(response);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<void> deleteAccount(String id) async {
    try {
      await SupabaseService.client
          .from('social_accounts')
          .delete()
          .eq('id', id);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }
}
