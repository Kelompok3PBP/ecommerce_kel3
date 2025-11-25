import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Ganti dengan path model yang benar di project Anda
import '../model/receipt.dart'; 

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  List<PurchaseReceipt> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // Fungsi untuk memuat dan memparsing riwayat dari SharedPreferences
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJsonList = prefs.getStringList('purchase_history') ?? [];
    
    final loadedHistory = historyJsonList.map((jsonString) {
      final receiptMap = jsonDecode(jsonString) as Map<String, dynamic>;
      // Menggunakan model yang sudah Anda definisikan
      return PurchaseReceipt.fromJson(receiptMap); 
    }).toList();

    if (mounted) {
      setState(() {
        history = loadedHistory;
        isLoading = false;
      });
    }
  }

  String formatRupiah(double price) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
              ? const Center(child: Text('Anda belum memiliki riwayat pesanan.'))
              : RefreshIndicator(
                  onRefresh: _loadHistory, // Memuat ulang data saat di-swipe ke bawah
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return _buildOrderTile(context, item);
                    },
                  ),
                ),
    );
  }

  // Widget untuk menampilkan ringkasan satu item pesanan
  Widget _buildOrderTile(BuildContext context, PurchaseReceipt receipt) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        onTap: () {
          // Navigasi ke halaman detail pesanan, kirim map data
          context.go(
            '/purchase-receipt/${receipt.orderId}',
            extra: receipt.toJson(), 
          );
        },
        title: Text(
          // Menampilkan 8 digit terakhir ID sebagai referensi
          'Pesanan #${receipt.orderId.length > 8 ? receipt.orderId.substring(receipt.orderId.length - 8) : receipt.orderId}', 
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tanggal: ${receipt.orderDate.split(' ')[0]}'),
            Text('Metode: ${receipt.paymentMethod}'),
            Text(
              'Status: ${receipt.paymentStatus}',
              style: TextStyle(
                color: receipt.paymentStatus == 'Success' ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              formatRupiah(receipt.totalAmount),
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            Text(
              '${receipt.items.length} Barang',
              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}