import 'package:ecommerce/features/product/domain/entities/product.dart';

abstract class CartRepository {
  Future<void> addItem(Product product, int quantity);
  Future<void> removeItem(int productId);
  Future<void> updateQuantity(int productId, int quantity);
  Future<Map<Product, int>> getCart();
  Future<void> clearCart();
}
