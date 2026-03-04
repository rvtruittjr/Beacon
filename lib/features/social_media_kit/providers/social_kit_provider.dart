import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../brands/providers/brand_provider.dart';
import '../../brand_kit/providers/brand_kit_provider.dart';

/// Aggregated brand data needed for social media image generation.
class SocialKitData {
  final String brandName;
  final String primaryColorHex;
  final String? logoUrl;

  const SocialKitData({
    required this.brandName,
    required this.primaryColorHex,
    this.logoUrl,
  });
}

final socialKitDataProvider =
    FutureProvider.autoDispose<SocialKitData?>((ref) async {
  final brandId = ref.watch(currentBrandProvider);
  if (brandId == null) return null;

  final brand = ref.watch(activeBrandProvider).valueOrNull;
  final colors = ref.watch(brandColorsProvider).valueOrNull ?? [];
  final logos = ref.watch(brandLogosProvider).valueOrNull ?? [];

  final brandName = brand?.name ?? 'Brand';
  final primaryHex =
      colors.isNotEmpty ? colors.first.hex : '#6C63FF';
  final logoUrl = logos.isNotEmpty ? logos.first['file_url'] as String? : null;

  return SocialKitData(
    brandName: brandName,
    primaryColorHex: primaryHex,
    logoUrl: logoUrl,
  );
});
