class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException() : super('Invalid email or password');
}

class UserAlreadyExistsException extends AuthException {
  UserAlreadyExistsException() : super('User with this email already exists');
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
  @override
  String toString() => message;
}
