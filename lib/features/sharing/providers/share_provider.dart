import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../brands/models/brand_model.dart';
import '../data/share_repository.dart';
import '../models/share_access_model.dart';

/// Share settings for the current brand.
final shareSettingsProvider =
    FutureProvider.autoDispose<BrandModel?>((ref) async {
  final brandId = ref.watch(currentBrandProvider);
  if (brandId == null) return null;

  try {
    return await ref.watch(shareRepositoryProvider).getShareSettings(brandId);
  } catch (_) {
    return null;
  }
});

/// Access log for the current brand.
final accessLogProvider =
    FutureProvider.autoDispose<List<ShareAccessModel>>((ref) async {
  final brandId = ref.watch(currentBrandProvider);
  if (brandId == null) return [];

  return ref.watch(shareRepositoryProvider).getAccessLog(brandId);
});
