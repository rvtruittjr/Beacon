import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart' as app;
import '../../../core/errors/error_handler.dart';
import '../../../core/services/supabase_service.dart';
import '../models/asset_model.dart';

class AssetLibraryRepository {
  AssetLibraryRepository();

  Future<List<AssetModel>> getAssets({
    required String brandId,
    String? collectionId,
    String? searchQuery,
    List<String>? tagIds,
    String? fileType,
  }) async {
    try {
      var query = SupabaseService.client
          .from('assets')
          .select()
          .eq('brand_id', brandId);

      if (collectionId != null) {
        query = query.eq('collection_id', collectionId);
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('name', '%$searchQuery%');
      }
      if (fileType != null && fileType.isNotEmpty) {
        query = query.eq('file_type', fileType);
      }

      final response = await query.order('created_at', ascending: false);
      var assets = (response as List)
          .map((json) => AssetModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Filter by tags client-side if needed
      if (tagIds != null && tagIds.isNotEmpty) {
        final taggedAssetIds = <String>{};
        for (final tagId in tagIds) {
          final rows = await SupabaseService.client
              .from('asset_tags')
              .select('asset_id')
              .eq('tag_id', tagId);
          for (final row in rows as List) {
            taggedAssetIds.add(row['asset_id'] as String);
          }
        }
        assets = assets.where((a) => taggedAssetIds.contains(a.id)).toList();
      }

      return assets;
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<AssetModel> uploadAsset({
    required String brandId,
    String? collectionId,
    required PlatformFile file,
    required String name,
  }) async {
    try {
      final client = SupabaseService.client;
      final user = client.auth.currentUser;
      if (user == null) {
        throw const app.AuthException('You must be signed in to upload assets.');
      }

      // Free tier enforcement
      final sub = await client
          .from('subscriptions')
          .select('plan')
          .eq('user_id', user.id)
          .maybeSingle();

      final plan = sub?['plan'] as String? ?? 'free';

      if (plan == 'free') {
        final existing = await client
            .from('assets')
            .select('id, file_size_bytes')
            .eq('brand_id', brandId);
        final assets = existing as List;

        if (assets.length >= 10) {
          throw const app.UpgradeRequiredException(
            'Free plan is limited to 10 assets',
            feature: 'asset_uploads',
          );
        }

        // Check 250MB total storage
        int totalBytes = 0;
        for (final a in assets) {
          totalBytes += ((a['file_size_bytes'] as num?) ?? 0).toInt();
        }
        if (totalBytes + (file.size) > 250 * 1024 * 1024) {
          throw const app.UpgradeRequiredException(
            'Free plan is limited to 250MB storage',
            feature: 'storage_limit',
          );
        }
      }

      // Upload to storage
      final path = '${user.id}/$brandId/assets/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      await client.storage.from('brand-assets').uploadBinary(
            path,
            file.bytes!,
            fileOptions: FileOptions(upsert: true),
          );

      final url = client.storage.from('brand-assets').getPublicUrl(path);

      // Determine file type and mime type from extension
      String? fileType;
      String mimeType;
      final ext = file.extension?.toLowerCase() ?? '';
      if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'].contains(ext)) {
        fileType = 'image';
        final mimeExt = ext == 'jpg' ? 'jpeg' : ext == 'svg' ? 'svg+xml' : ext;
        mimeType = 'image/$mimeExt';
      } else if (['mp4', 'mov', 'webm', 'avi'].contains(ext)) {
        fileType = 'video';
        mimeType = 'video/$ext';
      } else if (['pdf', 'doc', 'docx', 'xls', 'xlsx'].contains(ext)) {
        fileType = 'document';
        mimeType = ext == 'pdf' ? 'application/pdf' : 'application/$ext';
      } else if (['ttf', 'otf', 'woff', 'woff2'].contains(ext)) {
        fileType = 'font';
        mimeType = 'font/$ext';
      } else {
        mimeType = 'application/octet-stream';
      }

      final response = await client.from('assets').insert({
        'brand_id': brandId,
        'collection_id': collectionId,
        'user_id': user.id,
        'name': name,
        'file_url': url,
        'file_type': fileType,
        'mime_type': mimeType,
        'file_size_bytes': file.size,
      }).select().single();

      return AssetModel.fromJson(response);
    } catch (e, stack) {
      if (e is app.AppException) rethrow;
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<AssetModel> updateAsset(
    String id, {
    String? name,
    String? collectionId,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (collectionId != null) updates['collection_id'] = collectionId;

      final response = await SupabaseService.client
          .from('assets')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return AssetModel.fromJson(response);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<void> deleteAsset(String id) async {
    try {
      await SupabaseService.client.from('assets').delete().eq('id', id);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<List<AssetCollectionModel>> getCollections(String brandId) async {
    try {
      final response = await SupabaseService.client
          .from('asset_collections')
          .select()
          .eq('brand_id', brandId)
          .order('sort_order');

      return (response as List)
          .map((json) =>
              AssetCollectionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<AssetCollectionModel> createCollection({
    required String brandId,
    required String name,
  }) async {
    try {
      final response = await SupabaseService.client
          .from('asset_collections')
          .insert({
            'brand_id': brandId,
            'name': name,
          })
          .select()
          .single();

      return AssetCollectionModel.fromJson(response);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<List<TagModel>> getTags(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('tags')
          .select()
          .eq('user_id', userId)
          .order('name');

      return (response as List)
          .map((json) => TagModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<void> addTagToAsset(String assetId, String tagId) async {
    try {
      await SupabaseService.client.from('asset_tags').insert({
        'asset_id': assetId,
        'tag_id': tagId,
      });
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<void> removeTagFromAsset(String assetId, String tagId) async {
    try {
      await SupabaseService.client
          .from('asset_tags')
          .delete()
          .eq('asset_id', assetId)
          .eq('tag_id', tagId);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }
}
