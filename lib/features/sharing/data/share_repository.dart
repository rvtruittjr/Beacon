import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../brands/models/brand_model.dart';
import '../models/share_access_model.dart';

final shareRepositoryProvider = Provider<ShareRepository>((ref) {
  return ShareRepository();
});

class ShareRepository {
  /// Fetch share settings for a brand.
  Future<BrandModel> getShareSettings(String brandId) async {
    final client = SupabaseService.client;
    final response = await client
        .from('brands')
        .select()
        .eq('id', brandId)
        .single();

    return BrandModel.fromJson(response);
  }

  /// Update share settings (toggle, password, expiry).
  Future<void> updateShareSettings(
    String brandId, {
    bool? isPublic,
    String? password,
    DateTime? expiresAt,
  }) async {
    final client = SupabaseService.client;
    final updates = <String, dynamic>{};

    if (isPublic != null) updates['is_public'] = isPublic;
    if (password != null) updates['share_password_hash'] = password;
    if (expiresAt != null) {
      updates['share_expires_at'] = expiresAt.toIso8601String();
    }

    if (updates.isNotEmpty) {
      await client.from('brands').update(updates).eq('id', brandId);
    }
  }

  /// Clear expiry date.
  Future<void> clearExpiry(String brandId) async {
    final client = SupabaseService.client;
    await client
        .from('brands')
        .update({'share_expires_at': null}).eq('id', brandId);
  }

  /// Clear password.
  Future<void> clearPassword(String brandId) async {
    final client = SupabaseService.client;
    await client
        .from('brands')
        .update({'share_password_hash': null}).eq('id', brandId);
  }

  /// Reset share token — generates a new random token, invalidating the old URL.
  Future<String> resetShareToken(String brandId) async {
    final client = SupabaseService.client;
    final newToken = _generateToken();

    await client
        .from('brands')
        .update({'share_token': newToken}).eq('id', brandId);

    return newToken;
  }

  /// Fetch access log entries.
  Future<List<ShareAccessModel>> getAccessLog(String brandId,
      {int limit = 20}) async {
    final client = SupabaseService.client;

    try {
      final response = await client
          .from('share_access_log')
          .select()
          .eq('brand_id', brandId)
          .order('accessed_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) =>
              ShareAccessModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Verify share password against a token (calls Edge Function).
  Future<bool> verifySharePassword(String shareToken, String password) async {
    final client = SupabaseService.client;

    try {
      final response = await client.functions.invoke(
        'verify-share-password',
        body: {
          'share_token': shareToken,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>?;
      return data?['valid'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Fetch a brand by its share token (for public view).
  Future<BrandModel?> getBrandByShareToken(String token) async {
    final client = SupabaseService.client;

    final response = await client
        .from('brands')
        .select()
        .eq('share_token', token)
        .maybeSingle();

    if (response == null) return null;
    return BrandModel.fromJson(response);
  }

  static String _generateToken() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rng = Random.secure();
    return List.generate(24, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}
