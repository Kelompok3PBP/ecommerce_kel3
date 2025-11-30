import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ecommerce/app/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart' as sp;
import 'package:go_router/go_router.dart';
import 'package:ecommerce/features/cart/presentation/cubits/cart_cubit.dart';
import 'package:ecommerce/features/settings/data/localization_extension.dart';

class PaymentPage extends StatefulWidget {
  final double total;
  const PaymentPage({super.key, required this.total});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? selectedMethod;

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
            Text(
              '${context.t('cart_total')} ${formatRupiah(widget.total)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24.0),
            Text(context.t('payment_method'), style: TextStyle(fontSize: 16)),
            RadioListTile<String>(
              value: 'Transfer Bank',
              groupValue: selectedMethod,
              title: Text('Transfer Bank', style: TextStyle(fontSize: 15)),
              onChanged: (v) => setState(() => selectedMethod = v),
            ),
            RadioListTile<String>(
              value: 'E-Wallet (OVO, DANA, GoPay)',
              groupValue: selectedMethod,
              title: Text(
                'E-Wallet (OVO, DANA, GoPay)',
                style: TextStyle(fontSize: 15),
              ),
              onChanged: (v) => setState(() => selectedMethod = v),
            ),
            RadioListTile<String>(
              value: 'Bayar di Tempat (COD)',
              groupValue: selectedMethod,
              title: Text(
                'Bayar di Tempat (COD)',
                style: TextStyle(fontSize: 15),
              ),
              onChanged: (v) => setState(() => selectedMethod = v),
            ),
            const Spacer(),
            ElevatedButton(
              style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                minimumSize: MaterialStateProperty.all(
                  const Size(double.infinity, 56.0),
                ),
              ),
              onPressed: selectedMethod == null
                  ? null
                  : () async {
                      final prefs = await sp.SharedPreferences.getInstance();
                      final email = prefs.getString('current_user') ?? '';
                      final name = prefs.getString('current_user_name') ?? '';
                      final phone = prefs.getString('current_user_phone') ?? '';
                      final address = prefs.getString('selected_address') ?? '';

                      List<Map<String, dynamic>> items = [];
                      double subtotal = 0;

                      try {
                        // First try to read selected checkout items saved by CartPage
                        final selJson = prefs.getString('selected_checkout');
                        if (selJson != null) {
                          final parsed = jsonDecode(selJson) as List<dynamic>;
                          for (var entry in parsed) {
                            final Map<String, dynamic> m =
                                Map<String, dynamic>.from(entry as Map);
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

                      final orderId = DateTime.now().millisecondsSinceEpoch
                          .toString();
                      final orderDate = DateFormat(
                        'yyyy-MM-dd HH:mm:ss',
                      ).format(DateTime.now());

                      final receiptMap = {
                        'order_id': orderId,
                        'order_date': orderDate,
                        'customer_name': name.isNotEmpty ? name : email,
                        'customer_email': email,
                        'customer_phone': phone,
                        'shipping_address': address,
                        'items': items,
                        'subtotal': subtotal,
                        'shipping_cost': 0,
                        'tax': 0,
                        'discount': 0,
                        'total_amount': widget.total,
                        'payment_method': selectedMethod,
                        'payment_status': 'Success',
                        'purchase_structure': 'Pembayaran Penuh',
                        'installment_months': 0,
                        'installment_amount': 0,
                      };

                      final receiptJson = jsonEncode(receiptMap);
                      final historyList =
                          prefs.getStringList('purchase_history') ?? [];
                      historyList.insert(0, receiptJson);
                      await prefs.setStringList(
                        'purchase_history',
                        historyList,
                      );

                      // Clear cart and temporary selected list
                      context.read<CartCubit>().clear();
                      await prefs.remove('selected_checkout');

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
              child: Text(context.t('pay_now'), style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
