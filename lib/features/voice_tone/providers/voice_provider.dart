import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../data/voice_repository.dart';
import '../models/voice_model.dart';

final voiceRepositoryProvider = Provider<VoiceRepository>((ref) {
  return VoiceRepository();
});

final voiceProvider =
    FutureProvider.autoDispose<VoiceModel?>((ref) async {
  final brandId = ref.watch(currentBrandProvider);
  if (brandId == null) return null;

  return ref.watch(voiceRepositoryProvider).getVoice(brandId);
});

final voiceExamplesProvider =
    FutureProvider.autoDispose<List<VoiceExampleModel>>((ref) async {
  final brandId = ref.watch(currentBrandProvider);
  if (brandId == null) return [];

  return ref.watch(voiceRepositoryProvider).getVoiceExamples(brandId);
});

/// Notifier that holds in-memory voice state and auto-saves with 800ms debounce.
class VoiceEditorNotifier extends StateNotifier<VoiceModel> {
  VoiceEditorNotifier(this._repository, this._brandId, VoiceModel initial)
      : super(initial);

  final VoiceRepository _repository;
  final String _brandId;
  Timer? _debounce;

  void _scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      _repository.upsertVoice(_brandId, state);
    });
  }

  void setArchetype(String archetype) {
    state = state.copyWith(archetype: archetype);
    _scheduleSave();
  }

  void setToneFormal(int value) {
    state = state.copyWith(toneFormal: value);
    _scheduleSave();
  }

  void setToneSerious(int value) {
    state = state.copyWith(toneSerious: value);
    _scheduleSave();
  }

  void setToneBold(int value) {
    state = state.copyWith(toneBold: value);
    _scheduleSave();
  }

  void setMissionStatement(String value) {
    state = state.copyWith(missionStatement: value);
    _scheduleSave();
  }

  void setTagline(String value) {
    state = state.copyWith(tagline: value);
    _scheduleSave();
  }

  void addWordWeUse(String word) {
    final updated = List<String>.from(state.wordsWeUse)..add(word);
    state = state.copyWith(wordsWeUse: updated);
    _scheduleSave();
  }

  void removeWordWeUse(String word) {
    final updated = List<String>.from(state.wordsWeUse)..remove(word);
    state = state.copyWith(wordsWeUse: updated);
    _scheduleSave();
  }

  void addWordWeAvoid(String word) {
    final updated = List<String>.from(state.wordsWeAvoid)..add(word);
    state = state.copyWith(wordsWeAvoid: updated);
    _scheduleSave();
  }

  void removeWordWeAvoid(String word) {
    final updated = List<String>.from(state.wordsWeAvoid)..remove(word);
    state = state.copyWith(wordsWeAvoid: updated);
    _scheduleSave();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
