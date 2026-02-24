import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/app_providers.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenOrNull(
        data: (state) => state.session != null,
      ) ??
      false;
});

final hasCompletedOnboardingProvider = FutureProvider<bool>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return false;

  final response = await client
      .from('brands')
      .select('id')
      .eq('user_id', user.id)
      .eq('onboarding_complete', true)
      .limit(1);

  return (response as List).isNotEmpty;
});
