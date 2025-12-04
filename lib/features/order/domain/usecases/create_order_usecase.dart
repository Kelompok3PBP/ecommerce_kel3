import 'package:ecommerce/features/order/domain/entities/purchase_receipt.dart';
import 'package:ecommerce/features/order/domain/repositories/order_repository.dart';
import '../../../shipping/domain/entities/shipping_option.dart';
import '../../../product/domain/entities/product.dart';
import '../../../address/domain/entities/address.dart';

class CreateOrderUseCase {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  Future<PurchaseReceipt> call({
    required Map<Product, int> cartItems,
    required double subtotal,
    required double tax,
    required double discount,

    required Address shippingAddress,
    required ShippingOption selectedShippingOption,

    required String paymentMethod,
    required Map<String, dynamic> additionalOrderData,
  }) async {
    final double finalShippingCost = selectedShippingOption.cost;
    final double initialTotal = subtotal + tax - discount;
    final double totalAmount = initialTotal + finalShippingCost;

    final List<Map<String, dynamic>> orderItems = cartItems.entries.map((
      entry,
    ) {
      final product = entry.key;
      final quantity = entry.value;

      final double itemWeight = (product.weight ?? 0.0);

      return {
        'productId': product.id,
        'productTitle': product.title,
        'price': product.price,
        'quantity': quantity,
        'totalPrice': product.price * quantity,
        'itemWeight': itemWeight,
        'totalWeight': itemWeight * quantity,
        'productDetail': product.toJson(),
      };
    }).toList();

    final orderData = {
      ...additionalOrderData,

      'items': orderItems,
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,

      'shippingAddress': shippingAddress.toJson(),
      'selectedShippingOption': selectedShippingOption.toJson(),

      'shippingCost': finalShippingCost,
      'totalAmount': totalAmount,

      'paymentMethod': paymentMethod,
      'paymentStatus': 'Pending',
    };

    return await repository.createOrder(orderData);
  }
}
