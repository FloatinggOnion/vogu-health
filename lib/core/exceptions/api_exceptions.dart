/// Base exception class for API-related errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Exception thrown when there's a network-related error
class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

/// Exception thrown when there's a validation error
class ValidationException extends ApiException {
  final Map<String, String>? errors;

  ValidationException(String message, {this.errors}) : super(message);

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      return 'ValidationException: $message\nErrors: ${errors!.entries.map((e) => '${e.key}: ${e.value}').join('\n')}';
    }
    return 'ValidationException: $message';
  }
}

/// Exception thrown when there's a serialization error
class SerializationException extends ApiException {
  SerializationException(String message) : super(message);
}

/// Exception thrown when there's a client-side error (400)
class ClientException extends ApiException {
  ClientException(String message, int statusCode) : super(message, statusCode: statusCode);
}

/// Exception thrown when there's an authentication error (401)
class AuthenticationException extends ApiException {
  AuthenticationException(String message) : super(message, statusCode: 401);
}

/// Exception thrown when there's no data found (404)
class NoDataException extends ApiException {
  NoDataException(String message) : super(message, statusCode: 404);
}

/// Exception thrown when there's a timeout (408)
class TimeoutException extends ApiException {
  TimeoutException(String message) : super(message, statusCode: 408);
}

/// Exception thrown when rate limit is exceeded (429)
class RateLimitException extends ApiException {
  RateLimitException(String message) : super(message, statusCode: 429);
}

/// Exception thrown when there's a server error (500+)
class ServerException extends ApiException {
  ServerException(String message, int statusCode) : super(message, statusCode: statusCode);
}

/// Exception for configuration errors
class ConfigurationException extends ApiException {
  ConfigurationException(String message) : super(message);
}

/// Exception for cache-related errors
class CacheException extends ApiException {
  CacheException(String message) : super(message);
}

/// Exception for invalid date ranges
class InvalidDateRangeException extends ApiException {
  InvalidDateRangeException(String message) : super(message);
} 