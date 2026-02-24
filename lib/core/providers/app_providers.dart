import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return SupabaseService.client;
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
});

final currentUserProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return null;

  try {
    return await client
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();
  } catch (_) {
    return null;
  }
});

final currentBrandProvider = StateProvider<String?>((ref) => null);

final subscriptionProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return null;

  try {
    return await client
        .from('subscriptions')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();
  } catch (_) {
    return null;
  }
});
