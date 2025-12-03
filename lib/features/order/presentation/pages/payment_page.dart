// Path: lib/features/payment/presentation/pages/payment_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ecommerce/app/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart' as sp;
import 'package:go_router/go_router.dart';
import 'package:ecommerce/features/cart/presentation/cubits/cart_cubit.dart';
import 'package:ecommerce/features/settings/data/localization_extension.dart';
import 'package:ecommerce/features/shipping/domain/entities/shipping_option.dart'; // Import ShippingOption

class PaymentPage extends StatefulWidget {
  final double total;
  const PaymentPage({super.key, required this.total});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? selectedMethod;
  double shippingCost = 0.0;
  ShippingOption? selectedShippingOption;

  @override
  void initState() {
    super.initState();
    _loadShippingData();
  }

  // Fungsi untuk memuat data pengiriman
  Future<void> _loadShippingData() async {
    final prefs = await sp.SharedPreferences.getInstance();
    final shippingJson = prefs.getString('selected_shipping_option');

    if (shippingJson != null) {
      final Map<String, dynamic> map = jsonDecode(shippingJson);
      setState(() {
        selectedShippingOption = ShippingOption.fromJson(map);
        shippingCost = selectedShippingOption!.cost;
      });
    }
  }

  String formatRupiah(double price) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(price);
  }

  @override
  Widget build(BuildContext context) {
    // Total Akhir = Total Item + Biaya Kirim
    final finalTotal = widget.total + shippingCost;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/cart'),
        ),
        title: Text(
          context.t('payment'),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Detail Pengiriman ---
            _buildShippingDetails(),
            const SizedBox(height: 12.0),
            // --- Total Pembayaran ---
            Text(
              '${context.t('final_total_payment')}: ${formatRupiah(finalTotal)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24.0),
            Text(context.t('payment_method'), style: const TextStyle(fontSize: 16)),
            // --- Pilihan Metode Pembayaran (Tetap sama) ---
            RadioListTile<String>(
              value: 'Transfer Bank',
              groupValue: selectedMethod,
              title: const Text('Transfer Bank', style: TextStyle(fontSize: 15)),
              onChanged: (v) => setState(() => selectedMethod = v),
            ),
            RadioListTile<String>(
              value: 'E-Wallet (OVO, DANA, GoPay)',
              groupValue: selectedMethod,
              title: const Text(
                'E-Wallet (OVO, DANA, GoPay)',
                style: TextStyle(fontSize: 15),
              ),
              onChanged: (v) => setState(() => selectedMethod = v),
            ),
            RadioListTile<String>(
              value: 'Bayar di Tempat (COD)',
              groupValue: selectedMethod,
              title: const Text(
                'Bayar di Tempat (COD)',
                style: TextStyle(fontSize: 15),
              ),
              onChanged: (v) => setState(() => selectedMethod = v),
            ),
            const Spacer(),
            // --- Tombol Bayar ---
            ElevatedButton(
              style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                minimumSize: MaterialStateProperty.all(
                  const Size(double.infinity, 56.0),
                ),
              ),
              onPressed: selectedMethod == null || selectedShippingOption == null
                  ? null
                  : () async {
                      final prefs = await sp.SharedPreferences.getInstance();
                      final email = prefs.getString('current_user') ?? '';
                      final name = prefs.getString('current_user_name') ?? '';
                      final phone = prefs.getString('current_user_phone') ?? '';
                      final address = prefs.getString('selected_address') ?? '';

                      List<Map<String, dynamic>> items = [];
                      double subtotal = 0;

                      // Logika Pengambilan Item Cart (Tetap Sama)
                      try {
                        final selJson = prefs.getString('selected_checkout');
                        if (selJson != null) {
                          final parsed = jsonDecode(selJson) as List<dynamic>;
                          for (var entry in parsed) {
                            final Map<String, dynamic> m = Map<String, dynamic>.from(entry as Map);
                            final qty = (m['quantity'] ?? 1) as num;
                            final price = (m['price'] ?? 0) as num;
                            items.add({
                              'product_id': m['product_id']?.toString() ?? '',
                              'product_name': m['product_name'] ?? '',
                              'product_image': m['product_image'] ?? '',
                              'quantity': qty.toInt(),
                              'price': price.toDouble(),
                              'subtotal': (price.toDouble() * qty.toDouble()),
                            });
                            subtotal += price.toDouble() * qty.toDouble();
                          }
                        } else {
                          final cartState = context.read<CartCubit>().state;
                          cartState.items.forEach((product, quantity) {
                            items.add({
                              'product_id': product.id.toString(),
                              'product_name': product.title,
                              'product_image': product.image,
                              'quantity': quantity,
                              'price': product.price,
                              'subtotal': product.price * quantity,
                            });
                            subtotal += product.price * quantity;
                          });
                        }
                      } catch (e) {
                        print('Error extracting cart items: $e');
                        items = [];
                        subtotal = widget.total;
                      }

                      final orderId = DateTime.now().millisecondsSinceEpoch.toString();
                      final orderDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

                      // --- MAP RECEIPT BARU (TAMBAH DETAIL PENGIRIMAN) ---
                      final receiptMap = {
                        'order_id': orderId,
                        'order_date': orderDate,
                        'customer_name': name.isNotEmpty ? name : email,
                        'customer_email': email,
                        'customer_phone': phone,
                        'shipping_address': address,
                        'items': items,
                        'subtotal': subtotal,
                        'shipping_cost': shippingCost, // Menggunakan biaya kirim yang dimuat
                        'tax': 0,
                        'discount': 0,
                        'total_amount': finalTotal, // Menggunakan total akhir
                        'payment_method': selectedMethod,
                        'payment_status': 'Success',
                        'purchase_structure': 'Pembayaran Penuh',
                        'installment_months': 0,
                        'installment_amount': 0,
                        // Detail Shipping Option di-embed
                        'selected_shipping_option': selectedShippingOption!.toJson(),
                      };

                      final receiptJson = jsonEncode(receiptMap);
                      final historyList = prefs.getStringList('purchase_history') ?? [];
                      historyList.insert(0, receiptJson);
                      
                      await prefs.setStringList('purchase_history', historyList);
                      
                      // Clear cart dan temporary selected list + shipping option
                      context.read<CartCubit>().clear();
                      await prefs.remove('selected_checkout');
                      await prefs.remove('selected_shipping_option'); // Hapus data pengiriman sementara

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.t('payment_success')),
                          backgroundColor: Colors.green,
                        ),
                      );

                      if (mounted) {
                        context.go(
                          '/purchase-receipt/$orderId',
                          extra: receiptMap,
                        );
                      }
                    },
              child: Text(context.t('pay_now'), style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingDetails() {
    if (selectedShippingOption == null) {
      return Text(
        'Pengiriman: Belum dipilih. Kembali ke keranjang untuk memilih.',
        style: TextStyle(color: Colors.red[700]),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Pengiriman:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 4),
        Text('Kurir: ${selectedShippingOption!.courierName} (${selectedShippingOption!.name})'),
        Text('Estimasi: ${selectedShippingOption!.estimate}'),
        Text('Biaya Kirim: ${formatRupiah(selectedShippingOption!.cost)}'),
      ],
    );
  }
}