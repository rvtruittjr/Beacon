import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/supabase_service.dart';
import '../models/archive_item_model.dart';

final archiveRepositoryProvider = Provider<ArchiveRepository>((ref) {
  return ArchiveRepository(ref);
});

class ArchiveRepository {
  ArchiveRepository(this._ref);
  final Ref _ref;

  /// Fetch archive items with optional platform/pillar filters and sort.
  Future<List<ArchiveItemModel>> getArchiveItems({
    required String brandId,
    String? platform,
    String? pillarId,
    String sortBy = 'created_at',
  }) async {
    final client = SupabaseService.client;

    var query = client
        .from('content_archive')
        .select('*, content_pillars(name, color)')
        .eq('brand_id', brandId);

    if (platform != null && platform.isNotEmpty) {
      query = query.eq('platform', platform);
    }
    if (pillarId != null && pillarId.isNotEmpty) {
      query = query.eq('pillar_id', pillarId);
    }

    final column = switch (sortBy) {
      'views' => 'views',
      'likes' => 'likes',
      'comments' => 'comments',
      _ => 'created_at',
    };

    final response = await query.order(column, ascending: false);
    return (response as List)
        .map((json) =>
            ArchiveItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Add a new archive item. Enforces free tier limit of 5 items.
  Future<ArchiveItemModel> addArchiveItem(ArchiveItemModel item) async {
    await _enforceFreeLimit(item.brandId);

    final client = SupabaseService.client;
    final response = await client
        .from('content_archive')
        .insert(item.toJson())
        .select('*, content_pillars(name, color)')
        .single();

    return ArchiveItemModel.fromJson(response);
  }

  /// Update an existing archive item.
  Future<ArchiveItemModel> updateArchiveItem(
      String id, ArchiveItemModel item) async {
    final client = SupabaseService.client;
    final response = await client
        .from('content_archive')
        .update(item.toJson())
        .eq('id', id)
        .select('*, content_pillars(name, color)')
        .single();

    return ArchiveItemModel.fromJson(response);
  }

  /// Delete an archive item.
  Future<void> deleteArchiveItem(String id) async {
    final client = SupabaseService.client;
    await client.from('content_archive').delete().eq('id', id);
  }

  /// Check if video upload is allowed (Pro only).
  void enforceVideoUpload() {
    final sub = _ref.read(subscriptionProvider).valueOrNull;
    final plan = sub?['plan'] as String? ?? 'free';
    if (plan == 'free') {
      throw const UpgradeRequiredException(
        'Video archiving requires a Pro plan.',
        feature: 'video_archive',
      );
    }
  }

  Future<void> _enforceFreeLimit(String brandId) async {
    final sub = _ref.read(subscriptionProvider).valueOrNull;
    final plan = sub?['plan'] as String? ?? 'free';
    if (plan != 'free') return;

    final client = SupabaseService.client;
    final count = await client
        .from('content_archive')
        .select('id')
        .eq('brand_id', brandId);

    if ((count as List).length >= 5) {
      throw const UpgradeRequiredException(
        'Free plan allows up to 5 archive items. Upgrade to add more.',
        feature: 'archive_limit',
      );
    }
  }
}
