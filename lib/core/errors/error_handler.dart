import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import 'app_exception.dart';

class ErrorHandler {
  ErrorHandler._();

  static AppException handle(Object error, [StackTrace? stack]) {
    if (error is AppException) return error;

    if (error is supa.AuthException) {
      return AuthException(
        _friendlyAuthMessage(error.message),
        code: error.statusCode,
      );
    }

    if (error is supa.PostgrestException) {
      return DatabaseException(
        error.message,
        code: error.code,
      );
    }

    if (error is supa.StorageException) {
      return StorageException(
        error.message,
        code: error.statusCode,
      );
    }

    if (error is SocketException) {
      return const NetworkException(
        'No internet connection. Please check your network.',
        code: 'no_connection',
      );
    }

    return DatabaseException('Something went wrong. Please try again.');
  }

  static Never throwHandled(Object error, [StackTrace? stack]) {
    throw handle(error, stack);
  }

  static String _friendlyAuthMessage(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('invalid login credentials')) {
      return 'Incorrect email or password.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please confirm your email before signing in.';
    }
    if (lower.contains('user already registered')) {
      return 'An account with this email already exists.';
    }
    if (lower.contains('password')) {
      return 'Password must be at least 6 characters.';
    }
    if (lower.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment.';
    }
    return raw;
  }
}
