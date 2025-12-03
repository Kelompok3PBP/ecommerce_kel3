// lib/features/order/domain/usecases/create_order_usecase.dart (VERSI YANG DISESUAIKAN)

import 'package:ecommerce/features/order/domain/entities/purchase_receipt.dart';
import 'package:ecommerce/features/order/domain/repositories/order_repository.dart';
import '../../../shipping/domain/entities/shipping_option.dart'; // Dari fitur shipping
import '../../../product/domain/entities/product.dart'; // Dari fitur product (Diperlukan karena cart Anda menggunakan Product)
import '../../../address/domain/entities/address.dart'; // Dari fitur address

class CreateOrderUseCase {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  // ARGUMEN DIUBAH: Menerima Map<Product, int> (sesuai logic GetCartUseCase Anda)
  Future<PurchaseReceipt> call({
    // 1. DATA KERANJANG & HARGA
    required Map<Product, int> cartItems, // DIUBAH
    required double subtotal,
    required double tax,
    required double discount,

    // 2. DATA PENGIRIMAN
    required Address shippingAddress, 
    required ShippingOption selectedShippingOption, 
    
    // 3. DATA PEMBAYARAN & LAINNYA
    required String paymentMethod,
    required Map<String, dynamic> additionalOrderData, 
  }) async {
    // 1. HITUNG TOTAL AKHIR
    final double finalShippingCost = selectedShippingOption.cost;
    final double initialTotal = subtotal + tax - discount;
    final double totalAmount = initialTotal + finalShippingCost; 

    // 2. KONVERSI Map<Product, int> menjadi List of Map (format yang dibutuhkan untuk order data)
    final List<Map<String, dynamic>> orderItems = cartItems.entries.map((entry) {
      final product = entry.key;
      final quantity = entry.value;
      
      // Catatan: Karena Anda tidak menggunakan CartItem, asumsi berat (weight)
      // harus diimplementasikan di entitas Product atau di sini.
      final double itemWeight = (product.weight ?? 0.0); // ASUMSI: Product punya field 'weight'
      
      return {
        'productId': product.id,
        'productTitle': product.title,
        'price': product.price,
        'quantity': quantity,
        'totalPrice': product.price * quantity,
        'itemWeight': itemWeight, // Jika Product memiliki weight
        'totalWeight': itemWeight * quantity,
        'productDetail': product.toJson(),
      };
    }).toList();


    // 3. SUSUN DATA PESANAN FINAL
    final orderData = {
      ...additionalOrderData, 
      
      // Data Produk dan Harga
      'items': orderItems, // MENGGUNAKAN LIST YANG SUDAH DIBUAT
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      
      // Data Pengiriman (INTEGRASI KURIR)
      'shippingAddress': shippingAddress.toJson(), 
      'selectedShippingOption': selectedShippingOption.toJson(), 
      
      // Data Biaya Akhir
      'shippingCost': finalShippingCost, 
      'totalAmount': totalAmount, 
      
      // Data Pembayaran
      'paymentMethod': paymentMethod,
      'paymentStatus': 'Pending', 
    };

    // 4. PANGGIL REPOSITORI
    return await repository.createOrder(orderData);
  }
}