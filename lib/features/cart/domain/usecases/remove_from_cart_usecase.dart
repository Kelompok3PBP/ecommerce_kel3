import 'package:ecommerce/features/cart/domain/repositories/cart_repository.dart';

class RemoveFromCartUseCase {
  final CartRepository repository;

  RemoveFromCartUseCase(this.repository);

  Future<void> call(int productId) async {
    return await repository.removeItem(productId);
  }
}
