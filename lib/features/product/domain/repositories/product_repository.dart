import 'package:ecommerce/features/product/domain/entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getAll();
  Future<Product> getById(int id);
  Future<List<Product>> search(String query);
  Future<List<Product>> getByCategory(String category);
}
