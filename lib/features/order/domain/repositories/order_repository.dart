import 'package:ecommerce/features/order/domain/entities/purchase_receipt.dart';

abstract class OrderRepository {
  Future<PurchaseReceipt> createOrder(Map<String, dynamic> orderData);
  Future<PurchaseReceipt> getOrderById(String orderId);
  Future<List<PurchaseReceipt>> getOrderHistory();
  Future<void> saveOrderToHistory(PurchaseReceipt receipt);
}
