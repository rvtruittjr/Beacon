import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/services/supabase_service.dart';
import '../../audience/models/social_account_model.dart';
import '../../brands/models/brand_model.dart';

class SnapshotData {
  final BrandModel brand;
  final List<Map<String, dynamic>> colors;
  final List<Map<String, dynamic>> fonts;
  final Map<String, dynamic>? voice;
  final Map<String, dynamic>? audience;
  final List<Map<String, dynamic>> pillars;
  final List<Map<String, dynamic>> topContent;
  final List<Map<String, dynamic>> logos;
  final List<SocialAccountModel> socialAccounts;

  const SnapshotData({
    required this.brand,
    required this.colors,
    required this.fonts,
    this.voice,
    this.audience,
    required this.pillars,
    required this.topContent,
    required this.logos,
    required this.socialAccounts,
  });
}

final snapshotProvider = FutureProvider.autoDispose<SnapshotData>((ref) async {
  final brandId = ref.watch(currentBrandProvider);
  if (brandId == null) throw Exception('No brand selected');

  final client = SupabaseService.client;

  // Helper to safely query a table (returns fallback on 404 / missing table)
  Future<T> safeQuery<T>(Future<T> query, T fallback) async {
    try {
      return await query;
    } catch (_) {
      return fallback;
    }
  }

  final results = await Future.wait<dynamic>([
    // 0 – brand (required)
    client.from('brands').select().eq('id', brandId).single(),
    // 1-7 – optional sections (gracefully degrade)
    safeQuery(
      client.from('brand_colors').select().eq('brand_id', brandId).order('sort_order'),
      <dynamic>[],
    ),
    safeQuery(
      client.from('brand_fonts').select().eq('brand_id', brandId).order('sort_order'),
      <dynamic>[],
    ),
    safeQuery(
      client.from('brand_voice').select().eq('brand_id', brandId).maybeSingle(),
      null,
    ),
    safeQuery(
      client.from('brand_audience').select().eq('brand_id', brandId).maybeSingle(),
      null,
    ),
    safeQuery(
      client.from('content_pillars').select().eq('brand_id', brandId).order('sort_order'),
      <dynamic>[],
    ),
    safeQuery(
      client.from('content_archive').select().eq('brand_id', brandId).order('views', ascending: false).limit(3),
      <dynamic>[],
    ),
    safeQuery(
      client.from('assets').select().eq('brand_id', brandId).eq('file_type', 'logo'),
      <dynamic>[],
    ),
    // 8 – social accounts
    safeQuery(
      client.from('social_accounts').select().eq('brand_id', brandId).order('created_at'),
      <dynamic>[],
    ),
  ]);

  // Convert logo public URLs to signed URLs (bucket is private)
  final rawLogos = List<Map<String, dynamic>>.from(results[7] as List);
  final signedLogos = await _signLogoUrls(rawLogos);

  return SnapshotData(
    brand: BrandModel.fromJson(results[0] as Map<String, dynamic>),
    colors: List<Map<String, dynamic>>.from(results[1] as List),
    fonts: List<Map<String, dynamic>>.from(results[2] as List),
    voice: results[3] as Map<String, dynamic>?,
    audience: results[4] as Map<String, dynamic>?,
    pillars: List<Map<String, dynamic>>.from(results[5] as List),
    topContent: List<Map<String, dynamic>>.from(results[6] as List),
    logos: signedLogos,
    socialAccounts: (results[8] as List)
        .map((e) => SocialAccountModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
});

Future<List<Map<String, dynamic>>> _signLogoUrls(
  List<Map<String, dynamic>> logos,
) async {
  const bucket = 'brand-assets';
  const marker = '/object/public/$bucket/';

  final paths = <String>[];
  final pathIndices = <int>[];

  for (int i = 0; i < logos.length; i++) {
    final url = logos[i]['file_url'] as String? ?? '';
    final idx = url.indexOf(marker);
    if (idx != -1) {
      paths.add(url.substring(idx + marker.length).split('?').first);
      pathIndices.add(i);
    }
  }

  if (paths.isEmpty) return logos;

  final signed = await SupabaseService.client.storage
      .from(bucket)
      .createSignedUrls(paths, 3600);

  final result = logos.map((m) => Map<String, dynamic>.from(m)).toList();
  for (int i = 0; i < signed.length; i++) {
    final signedUrl = signed[i].signedUrl;
    if (signedUrl.isNotEmpty && i < pathIndices.length) {
      result[pathIndices[i]]['file_url'] = signedUrl;
    }
  }
  return result;
}
