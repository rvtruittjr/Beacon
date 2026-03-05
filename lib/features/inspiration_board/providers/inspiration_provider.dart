import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../data/inspiration_repository.dart';
import '../models/inspiration_item_model.dart';

final inspirationRepositoryProvider = Provider<InspirationRepository>((ref) {
  return InspirationRepository();
});

final inspirationItemsProvider =
    FutureProvider.autoDispose<List<InspirationItemModel>>((ref) async {
  final brandId = ref.watch(currentBrandProvider);
  if (brandId == null) return [];

  return ref.watch(inspirationRepositoryProvider).getItems(brandId);
});

/// In-memory state for responsive drag/resize — no DB round-trips during drag.
class BoardStateNotifier extends StateNotifier<List<InspirationItemModel>> {
  BoardStateNotifier() : super([]);

  void setItems(List<InspirationItemModel> items) => state = items;

  void moveItem(String id, double dx, double dy) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(posX: item.posX + dx, posY: item.posY + dy)
        else
          item,
    ];
  }

  void resizeItem(String id, double dw, double dh) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(
            width: (item.width + dw).clamp(80, 800),
            height: (item.height + dh).clamp(80, 800),
          )
        else
          item,
    ];
  }

  void updateItemData(String id, Map<String, dynamic> data) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(data: data) else item,
    ];
  }

  void removeItem(String id) {
    state = state.where((i) => i.id != id).toList();
  }

  void addItem(InspirationItemModel item) {
    state = [...state, item];
  }
}

final boardStateProvider =
    StateNotifierProvider<BoardStateNotifier, List<InspirationItemModel>>(
        (ref) {
  return BoardStateNotifier();
});
