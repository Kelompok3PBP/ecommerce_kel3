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
        padding: EdgeInsets.all(4.w), // <-- Layout Sizer OK
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${context.t('cart_total')} ${formatRupiah(widget.total)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 3.h), // <-- Layout Sizer OK
            Text(context.t('payment_method'), style: TextStyle(fontSize: 16)),
            RadioListTile<String>(
              value: 'Transfer Bank',
              groupValue: selectedMethod,
              title: Text(
                'Transfer Bank',
                style: TextStyle(fontSize: 15),
              ), // <-- GANTI DARI 12.sp
              onChanged: (v) => setState(() => selectedMethod = v),
            ),
            RadioListTile<String>(
              value: 'E-Wallet (OVO, DANA, GoPay)',
              groupValue: selectedMethod,
              title: Text(
                'E-Wallet (OVO, DANA, GoPay)',
                style: TextStyle(fontSize: 15),
              ), // <-- GANTI DARI 12.sp
              onChanged: (v) => setState(() => selectedMethod = v),
            ),
            RadioListTile<String>(
              value: 'Bayar di Tempat (COD)',
              groupValue: selectedMethod,
              title: Text(
                'Bayar di Tempat (COD)',
                style: TextStyle(fontSize: 15),
              ), // <-- GANTI DARI 12.sp
              onChanged: (v) => setState(() => selectedMethod = v),
            ),
            const Spacer(),
            ElevatedButton(
              style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                minimumSize: WidgetStateProperty.all(
                  Size(double.infinity, 6.h), // <-- Layout Sizer OK
                ),
              ),
              onPressed: selectedMethod == null
                  ? null
                  : () async {
                      context.read<CartCubit>().clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.t('payment_success')),
                          backgroundColor: Colors.green,
                        ),
                      );

                      if (mounted) {
                        final prefs = await SharedPreferences.getInstance();
                        final email = prefs.getString('current_user') ?? '';
                        context.go('/dashboard', extra: email);
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
