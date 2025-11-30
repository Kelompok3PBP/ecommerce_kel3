import 'package:ecommerce/features/order/domain/entities/purchase_receipt.dart';
import 'package:ecommerce/features/order/domain/repositories/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  Future<PurchaseReceipt> call(Map<String, dynamic> orderData) async {
    return await repository.createOrder(orderData);
  }
}
