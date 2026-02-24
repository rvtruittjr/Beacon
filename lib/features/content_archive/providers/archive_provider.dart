import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/services/supabase_service.dart';
import '../data/archive_repository.dart';
import '../models/archive_item_model.dart';

// ── Filter / sort state ────────────────────────────────────────

final archivePlatformFilterProvider = StateProvider<String?>((ref) => null);
final archivePillarFilterProvider = StateProvider<String?>((ref) => null);
final archiveSortProvider = StateProvider<String>((ref) => 'created_at');

// ── Content pillars for filter dropdown ─────────────────────────

final archivePillarsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final brandId = ref.watch(currentBrandProvider);
  if (brandId == null) return [];

  try {
    final response = await SupabaseService.client
        .from('content_pillars')
        .select('id, name, color')
        .eq('brand_id', brandId)
        .order('sort_order');

    return List<Map<String, dynamic>>.from(response);
  } catch (_) {
    return [];
  }
});

// ── Archive items list ──────────────────────────────────────────

final archiveItemsProvider =
    FutureProvider.autoDispose<List<ArchiveItemModel>>((ref) async {
  final brandId = ref.watch(currentBrandProvider);
  if (brandId == null) return [];

  final platform = ref.watch(archivePlatformFilterProvider);
  final pillarId = ref.watch(archivePillarFilterProvider);
  final sortBy = ref.watch(archiveSortProvider);

  return ref.watch(archiveRepositoryProvider).getArchiveItems(
        brandId: brandId,
        platform: platform,
        pillarId: pillarId,
        sortBy: sortBy,
      );
});
