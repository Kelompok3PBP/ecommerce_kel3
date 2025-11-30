abstract class Failure {
  final String message;
  Failure(this.message);
}

// Auth Failures
class AuthFailure extends Failure {
  AuthFailure(String message) : super(message);
}

class LoginFailure extends AuthFailure {
  LoginFailure(String message) : super(message);
}

class RegisterFailure extends AuthFailure {
  RegisterFailure(String message) : super(message);
}

class LogoutFailure extends AuthFailure {
  LogoutFailure(String message) : super(message);
}

// Product Failures
class ProductFailure extends Failure {
  ProductFailure(String message) : super(message);
}

class ProductNotFoundFailure extends ProductFailure {
  ProductNotFoundFailure(String message) : super(message);
}

class SearchFailure extends ProductFailure {
  SearchFailure(String message) : super(message);
}

// Cart Failures
class CartFailure extends Failure {
  CartFailure(String message) : super(message);
}

class AddToCartFailure extends CartFailure {
  AddToCartFailure(String message) : super(message);
}

// Order Failures
class OrderFailure extends Failure {
  OrderFailure(String message) : super(message);
}

class PaymentFailure extends OrderFailure {
  PaymentFailure(String message) : super(message);
}

// Network Failures
class NetworkFailure extends Failure {
  NetworkFailure(String message) : super(message);
}

// Server Failures
class ServerFailure extends Failure {
  ServerFailure(String message) : super(message);
}

// Cache Failures
class CacheFailure extends Failure {
  CacheFailure(String message) : super(message);
}
