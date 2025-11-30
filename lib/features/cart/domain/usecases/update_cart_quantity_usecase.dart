import 'package:ecommerce/features/cart/domain/repositories/cart_repository.dart';

class UpdateCartQuantityUseCase {
  final CartRepository repository;

  UpdateCartQuantityUseCase(this.repository);

  Future<void> call(int productId, int quantity) async {
    return await repository.updateQuantity(productId, quantity);
  }
}
