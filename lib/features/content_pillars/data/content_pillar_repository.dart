import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/supabase_service.dart';
import '../models/content_pillar_model.dart';

final contentPillarRepositoryProvider =
    Provider<ContentPillarRepository>((ref) {
  return ContentPillarRepository(ref);
});

class ContentPillarRepository {
  ContentPillarRepository(this._ref);
  final Ref _ref;

  Future<List<ContentPillarModel>> getPillars(String brandId) async {
    final response = await SupabaseService.client
        .from('content_pillars')
        .select()
        .eq('brand_id', brandId)
        .order('sort_order');

    return (response as List)
        .map((json) =>
            ContentPillarModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ContentPillarModel> addPillar(ContentPillarModel pillar) async {
    await _enforceFreeLimit(pillar.brandId);

    // Auto-assign sort_order as max + 1
    final existing = await SupabaseService.client
        .from('content_pillars')
        .select('sort_order')
        .eq('brand_id', pillar.brandId)
        .order('sort_order', ascending: false)
        .limit(1);

    final nextOrder = (existing as List).isNotEmpty
        ? ((existing.first as Map)['sort_order'] as int? ?? 0) + 1
        : 0;

    final data = pillar.copyWith(sortOrder: nextOrder).toJson();

    final response = await SupabaseService.client
        .from('content_pillars')
        .insert(data)
        .select()
        .single();

    return ContentPillarModel.fromJson(response);
  }

  Future<ContentPillarModel> updatePillar(
      String id, ContentPillarModel pillar) async {
    final response = await SupabaseService.client
        .from('content_pillars')
        .update(pillar.toJson())
        .eq('id', id)
        .select()
        .single();

    return ContentPillarModel.fromJson(response);
  }

  Future<void> deletePillar(String id) async {
    await SupabaseService.client.from('content_pillars').delete().eq('id', id);
  }

  Future<void> _enforceFreeLimit(String brandId) async {
    final sub = _ref.read(subscriptionProvider).valueOrNull;
    final plan = sub?['plan'] as String? ?? 'free';
    if (plan != 'free') return;

    final count = await SupabaseService.client
        .from('content_pillars')
        .select('id')
        .eq('brand_id', brandId);

    if ((count as List).length >= 5) {
      throw const UpgradeRequiredException(
        'Free plan allows up to 5 content pillars. Upgrade to add more.',
        feature: 'pillar_limit',
      );
    }
  }
}
