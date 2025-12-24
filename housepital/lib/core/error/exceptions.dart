/// Base exception class
abstract class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

/// Network related exceptions
class NetworkException extends AppException {
  NetworkException(super.message);
}

/// Server related exceptions
class ServerException extends AppException {
  ServerException(super.message);
}

/// Validation exceptions
class ValidationException extends AppException {
  final List<dynamic>? errors;

  ValidationException(super.message, {this.errors});

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      final errorMessages = errors!
          .map((e) => e['message'] ?? e.toString())
          .join(', ');
      return '$message: $errorMessages';
    }
    return message;
  }
}

/// Authentication exceptions
class UnauthorizedException extends AppException {
  UnauthorizedException(super.message);
}

/// Not found exceptions
class NotFoundException extends AppException {
  NotFoundException(super.message);
}

/// Cache exceptions
class CacheException extends AppException {
  CacheException(super.message);
}
