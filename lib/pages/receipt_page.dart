import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../model/receipt.dart';

class PurchaseReceiptPage extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic>? receiptData;

  const PurchaseReceiptPage({
    super.key,
    required this.orderId,
    this.receiptData,
  });

  @override
  Widget build(BuildContext context) {
    final receipt = receiptData != null
        ? PurchaseReceipt.fromJson(receiptData!)
        : _generateMockReceipt();

    final size = MediaQuery.of(context).size;
    final h = size.height;
    final w = size.width;

    // Semua ukuran disesuaikan ke tinggi layar agar pas 1 halaman
    final iconSize = h * 0.18;
    final fontLarge = h * 0.035;
    final fontMedium = h * 0.025;
    final fontSmall = h * 0.02;
    final cardPadding = h * 0.015;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Pembelian'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          width: w > 500 ? 500 : w, // batasi lebar maksimal
          height: h,
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.06,
            vertical: h * 0.02,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ===== Bagian Atas =====
              Column(
                children: [
                  Container(
                    width: iconSize * 1.3,
                    height: iconSize * 1.3,
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_circle,
                        color: Colors.green, size: iconSize),
                  ),
                  SizedBox(height: h * 0.01),
                  Text(
                    'Pembelian Berhasil!',
                    style: TextStyle(
                      fontSize: fontLarge,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  Text(
                    'Order ID: ${receipt.orderId}',
                    style: TextStyle(
                      fontSize: fontMedium,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),

              // ===== Informasi =====
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSectionCard(
                      title: 'Informasi Pembelian',
                      fontSize: fontMedium,
                      fontSmall: fontSmall,
                      padding: cardPadding,
                      children: [
                        _buildInfo('Nama', receipt.customerName, fontSmall),
                        _buildInfo('Status', receipt.paymentStatus, fontSmall,
                            isSuccess: true),
                        _buildInfo(
                            'Metode', receipt.paymentMethod, fontSmall),
                        _buildInfo('Tanggal', receipt.orderDate, fontSmall),
                        _buildInfo('Total',
                            'Rp${receipt.totalAmount.toString()}', fontSmall),
                      ],
                    ),
                  ],
                ),
              ),

              // ===== Tombol =====
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Download akan diimplementasi')),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: Text(
                        "Download",
                        style: TextStyle(fontSize: fontSmall),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: fontSmall),
                      ),
                    ),
                  ),
                  SizedBox(width: w * 0.03),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.go('/dashboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: fontSmall),
                      ),
                      child: Text(
                        "Selesai",
                        style: TextStyle(
                          fontSize: fontSmall,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    required double fontSize,
    required double fontSmall,
    required double padding,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(String label, String value, double fontSize,
      {bool isSuccess = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: fontSize, color: Colors.grey[700])),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: isSuccess ? Colors.green : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  PurchaseReceipt _generateMockReceipt() {
    return PurchaseReceipt(
      orderId: orderId,
      orderDate: DateTime.now().toString().split(' ').first,
      customerName: 'Rayhan Wahyu',
      customerEmail: 'rayhan@email.com',
      customerPhone: '08123456789',
      shippingAddress: 'Jl. Merdeka No. 123',
      items: [],
      subtotal: 0,
      shippingCost: 0,
      tax: 0,
      discount: 0,
      totalAmount: 125000,
      paymentMethod: 'QRIS',
      paymentStatus: 'Success',
      purchaseStructure: 'Pembayaran Penuh',
      installmentMonths: 0,
      installmentAmount: 0,
    );
  }
}
