import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../data/brand_repository.dart';
import '../models/brand_model.dart';

final brandRepositoryProvider = Provider<BrandRepository>((ref) {
  return BrandRepository();
});

final userBrandsProvider = FutureProvider<List<BrandModel>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];

  return ref.watch(brandRepositoryProvider).getUserBrands(user.id);
});

final activeBrandProvider = FutureProvider<BrandModel?>((ref) async {
  final brandId = ref.watch(currentBrandProvider);
  if (brandId == null) return null;

  return ref.watch(brandRepositoryProvider).getBrandById(brandId);
});
