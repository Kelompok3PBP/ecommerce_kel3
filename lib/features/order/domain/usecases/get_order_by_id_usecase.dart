import 'package:ecommerce/features/order/domain/entities/purchase_receipt.dart';
import 'package:ecommerce/features/order/domain/repositories/order_repository.dart';

class GetOrderByIdUseCase {
  final OrderRepository repository;

  GetOrderByIdUseCase(this.repository);

  Future<PurchaseReceipt> call(String orderId) async {
    return await repository.getOrderById(orderId);
  }
}
