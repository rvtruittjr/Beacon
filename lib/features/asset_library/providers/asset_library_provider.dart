import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../data/asset_library_repository.dart';
import '../models/asset_model.dart';

final assetLibraryRepositoryProvider = Provider<AssetLibraryRepository>((ref) {
  return AssetLibraryRepository();
});

// ─── Filter state ──────────────────────────────────────────────

class AssetFilterState {
  final String? collectionId;
  final String searchQuery;
  final String? fileType;
  final List<String> tagIds;

  const AssetFilterState({
    this.collectionId,
    this.searchQuery = '',
    this.fileType,
    this.tagIds = const [],
  });

  AssetFilterState copyWith({
    String? collectionId,
    String? searchQuery,
    String? fileType,
    List<String>? tagIds,
    bool clearCollection = false,
    bool clearFileType = false,
  }) {
    return AssetFilterState(
      collectionId: clearCollection ? null : (collectionId ?? this.collectionId),
      searchQuery: searchQuery ?? this.searchQuery,
      fileType: clearFileType ? null : (fileType ?? this.fileType),
      tagIds: tagIds ?? this.tagIds,
    );
  }
}

class AssetFilterNotifier extends StateNotifier<AssetFilterState> {
  AssetFilterNotifier() : super(const AssetFilterState());

  void setCollection(String? id) =>
      state = state.copyWith(collectionId: id, clearCollection: id == null);

  void setSearch(String query) =>
      state = state.copyWith(searchQuery: query);

  void setFileType(String? type) =>
      state = state.copyWith(fileType: type, clearFileType: type == null);

  void toggleTag(String tagId) {
    final current = List<String>.from(state.tagIds);
    if (current.contains(tagId)) {
      current.remove(tagId);
    } else {
      current.add(tagId);
    }
    state = state.copyWith(tagIds: current);
  }

  void clearAll() => state = const AssetFilterState();
}

final assetFilterProvider =
    StateNotifierProvider<AssetFilterNotifier, AssetFilterState>((ref) {
  return AssetFilterNotifier();
});

// ─── Data providers ────────────────────────────────────────────

final assetsProvider =
    FutureProvider.autoDispose<List<AssetModel>>((ref) async {
  final brandId = ref.watch(currentBrandProvider);
  if (brandId == null) return [];

  final filters = ref.watch(assetFilterProvider);
  return ref.watch(assetLibraryRepositoryProvider).getAssets(
        brandId: brandId,
        collectionId: filters.collectionId,
        searchQuery:
            filters.searchQuery.isEmpty ? null : filters.searchQuery,
        tagIds: filters.tagIds.isEmpty ? null : filters.tagIds,
        fileType: filters.fileType,
      );
});

final collectionsProvider =
    FutureProvider.autoDispose<List<AssetCollectionModel>>((ref) async {
  final brandId = ref.watch(currentBrandProvider);
  if (brandId == null) return [];

  return ref.watch(assetLibraryRepositoryProvider).getCollections(brandId);
});

final tagsProvider = FutureProvider.autoDispose<List<TagModel>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];

  return ref.watch(assetLibraryRepositoryProvider).getTags(user.id);
});
