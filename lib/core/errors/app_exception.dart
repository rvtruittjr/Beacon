sealed class AppException implements Exception {
  final String message;
  final String? code;
  const AppException(this.message, {this.code});
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code});
}

class StorageException extends AppException {
  const StorageException(super.message, {super.code});
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

class PermissionException extends AppException {
  const PermissionException(super.message, {super.code});
}

class UpgradeRequiredException extends AppException {
  final String feature;
  const UpgradeRequiredException(super.message,
      {required this.feature, super.code});
}
