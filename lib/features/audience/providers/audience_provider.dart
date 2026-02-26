import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../data/audience_repository.dart';
import '../data/social_account_repository.dart';
import '../models/audience_model.dart';
import '../models/social_account_model.dart';

final audienceRepositoryProvider = Provider<AudienceRepository>((ref) {
  return AudienceRepository();
});

final socialAccountRepositoryProvider =
    Provider<SocialAccountRepository>((ref) {
  return SocialAccountRepository();
});

final socialAccountsProvider =
    FutureProvider.autoDispose<List<SocialAccountModel>>((ref) async {
  final brandId = ref.watch(currentBrandProvider);
  if (brandId == null) return [];

  return ref.watch(socialAccountRepositoryProvider).getAccounts(brandId);
});

final audienceProvider =
    FutureProvider.autoDispose<AudienceModel?>((ref) async {
  final brandId = ref.watch(currentBrandProvider);
  if (brandId == null) return null;

  return ref.watch(audienceRepositoryProvider).getAudience(brandId);
});

/// Notifier that holds in-memory audience state and auto-saves with 800ms debounce.
class AudienceEditorNotifier extends StateNotifier<AudienceModel> {
  AudienceEditorNotifier(
    this._repository,
    this._brandId,
    AudienceModel initial,
  ) : super(initial);

  final AudienceRepository _repository;
  final String _brandId;
  Timer? _debounce;
  bool _dirty = false;
  bool _seeding = false;

  /// Seed the notifier from DB data without triggering saves.
  void seed(AudienceModel data) {
    _seeding = true;
    state = data.copyWith(brandId: _brandId);
    _seeding = false;
  }

  void _scheduleSave() {
    if (_seeding || _brandId.isEmpty) return;
    _dirty = true;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), _flush);
  }

  Future<void> _flush() async {
    if (!_dirty || _brandId.isEmpty) return;
    _dirty = false;
    try {
      await _repository.upsertAudience(_brandId, state);
    } catch (e) {
      // Mark dirty again so the next edit retries.
      _dirty = true;
    }
  }

  void setPersonaName(String value) {
    state = state.copyWith(personaName: value);
    _scheduleSave();
  }

  void setPersonaSummary(String value) {
    state = state.copyWith(personaSummary: value);
    _scheduleSave();
  }

  void setAgeRangeMin(int? value) {
    state = state.copyWith(ageRangeMin: value);
    _scheduleSave();
  }

  void setAgeRangeMax(int? value) {
    state = state.copyWith(ageRangeMax: value);
    _scheduleSave();
  }

  void setGenderSkew(String? value) {
    state = state.copyWith(genderSkew: value);
    _scheduleSave();
  }

  // ─── Tag list operations ──────────────────────────────────────

  void addLocation(String value) {
    final updated = List<String>.from(state.locations)..add(value);
    state = state.copyWith(locations: updated);
    _scheduleSave();
  }

  void removeLocation(String value) {
    final updated = List<String>.from(state.locations)..remove(value);
    state = state.copyWith(locations: updated);
    _scheduleSave();
  }

  void addInterest(String value) {
    final updated = List<String>.from(state.interests)..add(value);
    state = state.copyWith(interests: updated);
    _scheduleSave();
  }

  void removeInterest(String value) {
    final updated = List<String>.from(state.interests)..remove(value);
    state = state.copyWith(interests: updated);
    _scheduleSave();
  }

  void addPainPoint(String value) {
    final updated = List<String>.from(state.painPoints)..add(value);
    state = state.copyWith(painPoints: updated);
    _scheduleSave();
  }

  void removePainPoint(String value) {
    final updated = List<String>.from(state.painPoints)..remove(value);
    state = state.copyWith(painPoints: updated);
    _scheduleSave();
  }

  void addGoal(String value) {
    final updated = List<String>.from(state.goals)..add(value);
    state = state.copyWith(goals: updated);
    _scheduleSave();
  }

  void removeGoal(String value) {
    final updated = List<String>.from(state.goals)..remove(value);
    state = state.copyWith(goals: updated);
    _scheduleSave();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    // Flush any pending save before disposing.
    if (_dirty && _brandId.isNotEmpty) {
      _repository.upsertAudience(_brandId, state);
    }
    super.dispose();
  }
}
