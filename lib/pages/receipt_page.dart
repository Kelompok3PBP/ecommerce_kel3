import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../model/receipt.dart';

class PurchaseReceiptPage extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic>? receiptData;

  PurchaseReceiptPage({super.key, required this.orderId, this.receiptData});

  final currency = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final receipt = receiptData != null
        ? PurchaseReceipt.fromJson(receiptData!)
        : _generateMockReceipt();

    final size = MediaQuery.of(context).size;
    final h = size.height;
    final w = size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Struk Pembelian"), elevation: 0),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              _buildSuccessHeader(h),

              const SizedBox(height: 18),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildCard("Informasi Pembelian", [
                        _info("Nama", receipt.customerName),
                        _info("Tanggal", receipt.orderDate),
                        _info("Metode", receipt.paymentMethod),
                        _info(
                          "Status",
                          receipt.paymentStatus,
                          color: Colors.green,
                        ),
                        _info(
                          "Total",
                          currency.format(receipt.totalAmount),
                          isBold: true,
                        ),
                      ]),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _downloadPDF(receipt),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("Download PDF"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.go('/dashboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Selesai"),
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

  // -----------------------------------------------------
  // UI COMPONENTS
  // -----------------------------------------------------

  Widget _buildSuccessHeader(double h) {
    return Column(
      children: [
        Container(
          width: h * 0.15,
          height: h * 0.15,
          decoration: BoxDecoration(
            color: Colors.green[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_rounded,
            color: Colors.green[700],
            size: h * 0.12,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Pembelian Berhasil!",
          style: TextStyle(
            fontSize: h * 0.03,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _info(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------
  // PDF GENERATOR
  // -----------------------------------------------------

  Future<void> _downloadPDF(PurchaseReceipt receipt) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  "STRUK PEMBELIAN",
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Divider(),

              _pdfRow("Order ID", receipt.orderId),
              _pdfRow("Nama", receipt.customerName),
              _pdfRow("Tanggal", receipt.orderDate),
              _pdfRow("Metode", receipt.paymentMethod),
              _pdfRow("Status", receipt.paymentStatus),
              pw.SizedBox(height: 10),
              _pdfRow(
                "Total",
                currency.format(receipt.totalAmount),
                bold: true,
              ),

              pw.Divider(),
              pw.SizedBox(height: 24),
              pw.Center(
                child: pw.Text(
                  "Terima kasih telah melakukan pembelian!",
                  style: const pw.TextStyle(fontSize: 14),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: "Struk_${receipt.orderId}.pdf",
    );
  }

  pw.Widget _pdfRow(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // MOCK DATA -----------------------------------------

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
