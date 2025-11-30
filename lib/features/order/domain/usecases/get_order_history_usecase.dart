import 'package:ecommerce/features/order/domain/entities/purchase_receipt.dart';
import 'package:ecommerce/features/order/domain/repositories/order_repository.dart';

class GetOrderHistoryUseCase {
  final OrderRepository repository;

  GetOrderHistoryUseCase(this.repository);

  Future<List<PurchaseReceipt>> call() async {
    return await repository.getOrderHistory();
  }
}
