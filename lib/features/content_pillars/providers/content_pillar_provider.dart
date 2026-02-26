import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../data/content_pillar_repository.dart';
import '../models/content_pillar_model.dart';

final contentPillarsListProvider =
    FutureProvider.autoDispose<List<ContentPillarModel>>((ref) async {
  final brandId = ref.watch(currentBrandProvider);
  if (brandId == null) return [];
  return ref.watch(contentPillarRepositoryProvider).getPillars(brandId);
});
