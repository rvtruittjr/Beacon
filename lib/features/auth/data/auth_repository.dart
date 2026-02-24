import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart' as app;
import '../../../core/errors/error_handler.dart';
import '../../../core/services/supabase_service.dart';

class AuthRepository {
  AuthRepository();

  GoTrueClient get _auth => SupabaseService.client.auth;

  Future<void> signUpWithEmail(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      await _auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      // Update the users table with the full name
      final user = _auth.currentUser;
      if (user != null) {
        await SupabaseService.client
            .from('users')
            .update({'full_name': fullName}).eq('id', user.id);
      }
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithPassword(email: email, password: password);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<void> signInWithMagicLink(String email) async {
    try {
      await _auth.signInWithOtp(email: email);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _auth.signInWithOAuth(OAuthProvider.google);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.resetPasswordForEmail(email);
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.updateUser(UserAttributes(password: newPassword));
    } catch (e, stack) {
      ErrorHandler.throwHandled(e, stack);
    }
  }
}
