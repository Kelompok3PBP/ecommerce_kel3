import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../model/cart.dart';
import '../pages/dashboard_page.dart';

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
    final cart = Provider.of<CartModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // tampilkan total harga
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total yang harus dibayar:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    formatRupiah(widget.total),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Pilih Metode Pembayaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            RadioListTile<String>(
              value: 'BANK',
              groupValue: selectedMethod,
              title: const Text('Transfer Bank'),
              onChanged: (value) => setState(() => selectedMethod = value),
            ),
            RadioListTile<String>(
              value: 'E-WALLET',
              groupValue: selectedMethod,
              title: const Text('E-Wallet (OVO, GoPay, DANA)'),
              onChanged: (value) => setState(() => selectedMethod = value),
            ),
            RadioListTile<String>(
              value: 'COD',
              groupValue: selectedMethod,
              title: const Text('Bayar di Tempat (COD)'),
              onChanged: (value) => setState(() => selectedMethod = value),
            ),

            const Spacer(),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: selectedMethod == null
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Pembayaran berhasil dengan metode: $selectedMethod',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );

                        // kosongkan keranjang
                        cart.clear();

                        // tunggu 1 detik lalu arahkan ke dashboard (home)
                        Future.delayed(const Duration(seconds: 1), () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const DashboardPage(email: ''),
                            ),
                            (route) => false,
                          );
                        });
                      },
                child: const Text(
                  'Bayar Sekarang',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
