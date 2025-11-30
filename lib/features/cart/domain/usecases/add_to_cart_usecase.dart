import 'package:ecommerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:ecommerce/features/product/domain/entities/product.dart';

class AddToCartUseCase {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  Future<void> call(Product product, int quantity) async {
    return await repository.addItem(product, quantity);
  }
}
