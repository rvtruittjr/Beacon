import 'dart:async';

import 'package:flutter/foundation.dart';
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

/// Notifier that holds in-memory audience state with explicit save.
class AudienceEditorNotifier extends StateNotifier<AudienceModel> {
  AudienceEditorNotifier(
    this._repository,
    this._brandId,
    AudienceModel initial,
  ) : super(initial);

  final AudienceRepository _repository;
  final String _brandId;

  /// Seed the notifier from DB data without triggering saves.
  void seed(AudienceModel data) {
    state = data.copyWith(brandId: _brandId);
  }

  /// Explicitly save the current state to Supabase.
  /// Returns null on success, or an error message on failure.
  Future<String?> save() async {
    if (_brandId.isEmpty) return 'No brand selected';
    try {
      await _repository.upsertAudience(_brandId, state);
      return null; // success
    } catch (e) {
      return e.toString();
    }
  }

  void setPersonaName(String value) {
    state = state.copyWith(personaName: value);
  }

  void setPersonaSummary(String value) {
    state = state.copyWith(personaSummary: value);
  }

  void setAgeRangeMin(int? value) {
    state = state.copyWith(ageRangeMin: value);
  }

  void setAgeRangeMax(int? value) {
    state = state.copyWith(ageRangeMax: value);
  }

  void setGenderSkew(String? value) {
    state = state.copyWith(genderSkew: value);
  }

  // ─── Tag list operations ──────────────────────────────────────

  void addLocation(String value) {
    final updated = List<String>.from(state.locations)..add(value);
    state = state.copyWith(locations: updated);
  }

  void removeLocation(String value) {
    final updated = List<String>.from(state.locations)..remove(value);
    state = state.copyWith(locations: updated);
  }

  void addInterest(String value) {
    final updated = List<String>.from(state.interests)..add(value);
    state = state.copyWith(interests: updated);
  }

  void removeInterest(String value) {
    final updated = List<String>.from(state.interests)..remove(value);
    state = state.copyWith(interests: updated);
  }

  void addPainPoint(String value) {
    final updated = List<String>.from(state.painPoints)..add(value);
    state = state.copyWith(painPoints: updated);
  }

  void removePainPoint(String value) {
    final updated = List<String>.from(state.painPoints)..remove(value);
    state = state.copyWith(painPoints: updated);
  }

  void addGoal(String value) {
    final updated = List<String>.from(state.goals)..add(value);
    state = state.copyWith(goals: updated);
  }

  void removeGoal(String value) {
    final updated = List<String>.from(state.goals)..remove(value);
    state = state.copyWith(goals: updated);
  }
}
