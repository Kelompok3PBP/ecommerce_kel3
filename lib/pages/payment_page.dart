import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/cart.dart';

class PaymentPage extends StatefulWidget {
  final double total;
  const PaymentPage({super.key, required this.total});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? selectedMethod;

  // ✅ Fungsi ini sudah benar dan sekarang konsisten dengan halaman lain
  String formatRupiah(double price) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(price);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Pembayaran: ${formatRupiah(widget.total)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Text('Pilih Metode Pembayaran:', style: TextStyle(fontSize: 16)),
            RadioListTile<String>(value: 'Transfer Bank', groupValue: selectedMethod, title: const Text('Transfer Bank'), onChanged: (v) => setState(() => selectedMethod = v)),
            RadioListTile<String>(value: 'E-Wallet (OVO, DANA, GoPay)', groupValue: selectedMethod, title: const Text('E-Wallet (OVO, DANA, GoPay)'), onChanged: (v) => setState(() => selectedMethod = v)),
            RadioListTile<String>(value: 'Bayar di Tempat (COD)', groupValue: selectedMethod, title: const Text('Bayar di Tempat (COD)'), onChanged: (v) => setState(() => selectedMethod = v)),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: selectedMethod == null ? null : () async {
                cart.clear();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pembayaran berhasil!'), backgroundColor: Colors.green));
                
                if (mounted) {
                  final prefs = await SharedPreferences.getInstance();
                  final email = prefs.getString('current_user') ?? '';
                  Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false, arguments: email);
                }
              },
              child: const Text('Bayar Sekarang', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}