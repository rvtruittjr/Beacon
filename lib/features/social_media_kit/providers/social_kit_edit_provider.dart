import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/social_kit_edit_state.dart';

class SocialKitEditNotifier
    extends StateNotifier<Map<String, SocialKitEditState>> {
  SocialKitEditNotifier() : super({});

  SocialKitEditState getEdit(String presetKey) =>
      state[presetKey] ?? const SocialKitEditState();

  void updateEdit(String presetKey, SocialKitEditState edit) {
    state = {...state, presetKey: edit};
  }

  void resetEdit(String presetKey) {
    final next = {...state}..remove(presetKey);
    state = next;
  }
}

final socialKitEditProvider =
    StateNotifierProvider<SocialKitEditNotifier, Map<String, SocialKitEditState>>(
  (ref) => SocialKitEditNotifier(),
);
