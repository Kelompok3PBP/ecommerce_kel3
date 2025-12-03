import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ecommerce/app/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart' as sp;
import 'package:go_router/go_router.dart';
import 'package:ecommerce/features/cart/presentation/cubits/cart_cubit.dart';
import 'package:ecommerce/features/settings/data/localization_extension.dart';
import 'package:ecommerce/features/settings/data/notification_service.dart';
import 'package:ecommerce/features/shipping/domain/entities/shipping_option.dart';

class PaymentPage extends StatefulWidget {
  final dynamic extra;
  const PaymentPage({super.key, this.extra});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? selectedMethod;
  bool isBuyNow = false;
  Map<String, dynamic> buyNowData = {};
  double total = 0;
  ShippingOption? selectedShippingOption;

  @override
  void initState() {
    super.initState();
    // Check if this is from BUY NOW button
    if (widget.extra is Map) {
      isBuyNow = true;
      buyNowData = widget.extra as Map<String, dynamic>;
      total = buyNowData['total'] ?? 0;
    } else if (widget.extra is double) {
      total = widget.extra as double;
    }
    _loadShippingData();
  }

  Future<void> _loadShippingData() async {
    final prefs = await sp.SharedPreferences.getInstance();
    final shippingJson = prefs.getString('selected_shipping_option');
    if (shippingJson != null) {
      try {
        final shippingMap = jsonDecode(shippingJson) as Map<String, dynamic>;
        setState(() {
          selectedShippingOption = ShippingOption.fromJson(shippingMap);
        });
      } catch (e) {
        print('Error loading shipping option: $e');
      }
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (isBuyNow) {
              context.go('/detail/${buyNowData['productId']}');
            } else {
              context.go('/cart');
            }
          },
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
              '${context.t('cart_total')} ${formatRupiah(total)}',
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
                        // Check if this is from BUY NOW (direct checkout)
                        if (isBuyNow) {
                          items.add({
                            'product_id':
                                buyNowData['productId']?.toString() ?? '',
                            'product_name': buyNowData['productName'] ?? '',
                            'product_image': buyNowData['productImage'] ?? '',
                            'quantity': buyNowData['quantity'] ?? 1,
                            'price': buyNowData['price'] ?? 0,
                            'subtotal':
                                (buyNowData['price'] ?? 0) *
                                (buyNowData['quantity'] ?? 1),
                          });
                          subtotal = buyNowData['total'] ?? 0;
                        } else {
                          // Regular checkout from cart
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
                        }
                      } catch (e) {
                        print('Error extracting cart items: $e');
                        items = [];
                        subtotal = total;
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
                        'shipping_cost': selectedShippingOption?.cost ?? 0.0,
                        'tax': 0,
                        'discount': 0,
                        'total_amount': total,
                        'payment_method': selectedMethod,
                        'payment_status': 'Success',
                        'purchase_structure': 'Pembayaran Penuh',
                        'installment_months': 0,
                        'installment_amount': 0,
                        'selected_shipping_option':
                            selectedShippingOption != null
                            ? selectedShippingOption!.toJson()
                            : null,
                      };

                      final receiptJson = jsonEncode(receiptMap);
                      final historyList =
                          prefs.getStringList('purchase_history') ?? [];
                      historyList.insert(0, receiptJson);
                      await prefs.setStringList(
                        'purchase_history',
                        historyList,
                      );

                      // Clear cart and temporary selected list (only if from regular cart)
                      if (!isBuyNow) {
                        context.read<CartCubit>().clear();
                        await prefs.remove('selected_checkout');
                      }

                      // Show success popup only if notifications enabled
                      await NotificationService.showIfEnabledDialog(
                        context,
                        title: context.t('payment_success'),
                        body: context.t('payment_success'),
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
