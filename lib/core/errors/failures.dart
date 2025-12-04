abstract class Failure {
  final String message;
  Failure(this.message);
}

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

class ProductFailure extends Failure {
  ProductFailure(String message) : super(message);
}

class ProductNotFoundFailure extends ProductFailure {
  ProductNotFoundFailure(String message) : super(message);
}

class SearchFailure extends ProductFailure {
  SearchFailure(String message) : super(message);
}

class CartFailure extends Failure {
  CartFailure(String message) : super(message);
}

class AddToCartFailure extends CartFailure {
  AddToCartFailure(String message) : super(message);
}

class OrderFailure extends Failure {
  OrderFailure(String message) : super(message);
}

class PaymentFailure extends OrderFailure {
  PaymentFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  NetworkFailure(String message) : super(message);
}

class ServerFailure extends Failure {
  ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  CacheFailure(String message) : super(message);
}
