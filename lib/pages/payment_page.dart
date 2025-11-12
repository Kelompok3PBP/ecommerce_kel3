import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';
import '../bloc/cart_cubit.dart';
import '../services/localization_extension.dart';

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
      appBar: AppBar(title: Text(context.t('payment'))),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${context.t('cart_total')} ${formatRupiah(widget.total)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 3.h),
            Text(context.t('payment_method'), style: TextStyle(fontSize: 16)),
            RadioListTile<String>(
              value: 'Transfer Bank',
              groupValue: selectedMethod,
              title: Text(
                'Transfer Bank',
                style: TextStyle(fontSize: 15),
              ),
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
                  Size(double.infinity, 6.h),
                ),
              ),
              onPressed: selectedMethod == null
                  ? null
                  : () async {
                      // Prepare receipt data from cart (best-effort using dynamic access)
                      final prefs = await SharedPreferences.getInstance();
                      final email = prefs.getString('current_user') ?? '';
                      final name = prefs.getString('current_user_name') ?? '';
                      final phone = prefs.getString('current_user_phone') ?? '';
                      final address = prefs.getString('selected_address') ?? '';

                      List<Map<String, dynamic>> items = [];
                      double subtotal = 0;

                      try {
                        final cartState = context.read<CartCubit>().state;
                        final dynamic dyn = cartState;
                        final dynamic cartItems = dyn.items ?? dyn.cartItems ?? dyn.products ?? [];

                        for (var ci in (cartItems as List)) {
                          final dynamic it = ci;
                          final pid = it.productId ?? it.id ?? '';
                          final pname = it.productName ?? it.name ?? '';
                          final pimg = it.productImage ?? it.image ?? '';
                          final qty = it.quantity ?? it.qty ?? 1;
                          final price = (it.price ?? it.unitPrice ?? 0).toDouble();
                          final sub = (it.subtotal ?? (price * qty)).toDouble();

                          items.add({
                            'product_id': pid.toString(),
                            'product_name': pname.toString(),
                            'product_image': pimg.toString(),
                            'quantity': qty,
                            'price': price,
                            'subtotal': sub,
                          });
                          subtotal += sub;
                        }
                      } catch (_) {
                        // fallback: no items available
                        items = [];
                        subtotal = widget.total;
                      }

                      // build receipt map
                      final orderId = DateTime.now().millisecondsSinceEpoch.toString();
                      final orderDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
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

                      // clear cart then navigate to receipt page with data
                      context.read<CartCubit>().clear();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.t('payment_success')),
                          backgroundColor: Colors.green,
                        ),
                      );

                      if (mounted) {
                        context.go('/purchase-receipt/$orderId', extra: receiptMap);
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