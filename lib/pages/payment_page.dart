import 'package:flutter/material.dart'; // <--- INI YANG HILANG
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../bloc/cart_cubit.dart';

class PaymentPage extends StatefulWidget {
  final double total;
  const PaymentPage({super.key, required this.total});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? selectedMethod;

  // (Fungsi formatRupiah tidak berubah)
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
      appBar: AppBar(title: const Text('Pembayaran')),
      body: Padding(
        // Ganti padding statis
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Pembayaran: ${formatRupiah(widget.total)}',
              // Ganti fontSize statis
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            // Ganti SizedBox statis
            SizedBox(height: 3.h),
            Text(
              'Pilih Metode Pembayaran:',
              // Ganti fontSize statis
              style: TextStyle(fontSize: 13.sp),
            ),
            RadioListTile<String>(
              value: 'Transfer Bank',
              groupValue: selectedMethod,
              title: Text('Transfer Bank', style: TextStyle(fontSize: 12.sp)), // Ganti fontSize
              onChanged: (v) => setState(() => selectedMethod = v),
            ),
            RadioListTile<String>(
              value: 'E-Wallet (OVO, DANA, GoPay)',
              groupValue: selectedMethod,
              title: Text('E-Wallet (OVO, DANA, GoPay)', style: TextStyle(fontSize: 12.sp)), // Ganti fontSize
              onChanged: (v) => setState(() => selectedMethod = v),
            ),
            RadioListTile<String>(
              value: 'Bayar di Tempat (COD)',
              groupValue: selectedMethod,
              title: Text('Bayar di Tempat (COD)', style: TextStyle(fontSize: 12.sp)), // Ganti fontSize
              onChanged: (v) => setState(() => selectedMethod = v),
            ),
            const Spacer(),
            ElevatedButton(
              style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                    minimumSize: WidgetStateProperty.all(
                      // Ganti height statis
                      Size(double.infinity, 6.h),
                    ),
                  ),
              onPressed: selectedMethod == null
                  ? null
                  : () async {
                      context.read<CartCubit>().clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pembayaran berhasil!'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      if (mounted) {
                        final prefs = await SharedPreferences.getInstance();
                        final email = prefs.getString('current_user') ?? '';
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/dashboard',
                          (route) => false,
                          arguments: email,
                        );
                      }
                    },
              child: Text(
                'Bayar Sekarang',
                // Ganti fontSize statis
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}