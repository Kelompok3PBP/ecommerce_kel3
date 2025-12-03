// Path: lib/features/order/presentation/pages/purchase_receipt_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:ecommerce/features/order/domain/entities/purchase_receipt.dart';
import 'package:ecommerce/features/shipping/domain/entities/shipping_option.dart'; // Import ShippingOption
import 'package:ecommerce/app/theme/app_theme.dart';

class PurchaseReceiptPage extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic>? receiptData;

  PurchaseReceiptPage({super.key, required this.orderId, this.receiptData});

  final currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    // Pastikan kita mendapatkan data pengiriman dari receiptData
    final receipt = receiptData != null
        ? PurchaseReceipt.fromJson(receiptData!)
        : _generateMockReceipt(); // Panggil fungsi mock yang sudah diperbaiki

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = constraints.maxWidth;
            final double cardWidth = maxWidth > 600 ? 420.0 : maxWidth * 0.92;

            return Stack(
              children: [
                Container(decoration: const BoxDecoration(color: Colors.white)),
                SingleChildScrollView(
                  child: Center(
                    child: Container(
                      width: cardWidth,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _receiptCard(context, receipt),
                          const SizedBox(height: 16),
                          _actionButtons(context, receipt),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: IconButton(
                    icon: Icon(Icons.close, color: AppTheme.textPrimaryColor),
                    onPressed: () => context.pop(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ================= UI CARD =================

  Widget _receiptCard(BuildContext context, PurchaseReceipt receipt) {
    // Ambil detail ShippingOption
    final shippingOption = receipt.selectedShippingOption;
    final shippingDetails = shippingOption != null
        ? '${shippingOption.courierName} (${shippingOption.name})'
        : 'Tidak Dipilih';
    final shippingCostDisplay = currency.format(receipt.shippingCost);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.primaryColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            "Struk Pembelian",
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            currency.format(receipt.totalAmount),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _detailRow("Tanggal", receipt.orderDate),
          const SizedBox(height: 8),
          _detailRow("Metode Pembayaran", receipt.paymentMethod),
          const SizedBox(height: 8),
          _detailRow("No Referensi", receipt.orderId),
          const SizedBox(height: 8),
          _detailRow("Account", receipt.customerName),
          const SizedBox(height: 16),
          // --- DETAIL PENGIRIMAN ---
          _detailRow("Pengiriman", shippingDetails),
          const SizedBox(height: 8),
          _detailRow("Alamat Kirim", receipt.shippingAddress, isMultiline: true),
          const SizedBox(height: 16),
          // --------------------------
          const Divider(height: 2, color: AppTheme.primaryColor, thickness: 2),
          const SizedBox(height: 16),
          if (receipt.items.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              "Item yang Dibeli:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            ...receipt.items.map((item) {
              final itemMap = item is Map<String, dynamic> ? item : {};
              final name = itemMap['product_name'] ?? 'Item';
              final qty = itemMap['quantity'] ?? 1;
              final price = (itemMap['price'] ?? 0).toDouble();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$name (x$qty)',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 0,
                      child: Text(
                        currency.format(price * qty),
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 12),
            const Divider(height: 2, color: AppTheme.primaryColor, thickness: 1),
            const SizedBox(height: 12),
          ],
          _detailRow(
            "Subtotal Produk",
            currency.format(receipt.subtotal),
            isBold: true,
          ),
          const SizedBox(height: 8),
          _detailRow(
            "Biaya Kirim",
            shippingCostDisplay,
            isBold: true,
          ),
          const SizedBox(height: 8),
          _detailRow(
            "Total Akhir",
            currency.format(receipt.totalAmount),
            isBold: true,
            isPrimary: true,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    bool isBold = false,
    bool isPrimary = false,
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isPrimary
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondaryColor,
                fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: isPrimary
                    ? AppTheme.primaryColor
                    : AppTheme.textPrimaryColor,
              ),
              maxLines: isMultiline ? null : 2,
              overflow: isMultiline ? TextOverflow.clip : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ================= BUTTONS =================

  Widget _actionButtons(BuildContext context, PurchaseReceipt receipt) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _downloadPDF(receipt),
            icon: const Icon(Icons.download),
            label: const Text("Download PDF"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 2),
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/dashboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Kembali ke Dashboard",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // ================= PDF =================

  Future<void> _downloadPDF(PurchaseReceipt receipt) async {
    final pdf = pw.Document();

    // Ambil detail ShippingOption untuk PDF
    final shippingOption = receipt.selectedShippingOption;
    final shippingDetails = shippingOption != null
        ? '${shippingOption.courierName} (${shippingOption.name})'
        : 'Tidak Dipilih';

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
              // Detail Order
              _pdfRow("Order ID", receipt.orderId),
              _pdfRow("Nama", receipt.customerName),
              _pdfRow("Tanggal", receipt.orderDate),
              _pdfRow("Metode Pembayaran", receipt.paymentMethod),
              _pdfRow("Status Pembayaran", receipt.paymentStatus),
              // Detail Pengiriman
              _pdfRow("Pengiriman", shippingDetails),
              _pdfRow("Alamat Kirim", receipt.shippingAddress),
              // Subtotal, Biaya Kirim, Pajak (Opsional)
              pw.SizedBox(height: 10),
              pw.Divider(),
              _pdfRow("Subtotal Produk", currency.format(receipt.subtotal)),
              _pdfRow("Biaya Kirim", currency.format(receipt.shippingCost)),
              if (receipt.tax > 0) _pdfRow("Pajak", currency.format(receipt.tax)),
              pw.SizedBox(height: 10),
              _pdfRow(
                "TOTAL AKHIR",
                currency.format(receipt.totalAmount),
                bold: true,
              ),
              pw.Divider(),
              pw.SizedBox(height: 24),
              // Daftar Item
              if (receipt.items.isNotEmpty) ...[
                pw.Text(
                  "Rincian Item:",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                ...receipt.items.map((item) {
                  final itemMap = item is Map<String, dynamic> ? item : {};
                  final name = itemMap['product_name'] ?? 'Item';
                  final qty = itemMap['quantity'] ?? 1;
                  final price = (itemMap['price'] ?? 0).toDouble();
                  return _pdfRow(
                    '$name (x$qty)',
                    currency.format(price * qty),
                  );
                }).toList(),
                pw.SizedBox(height: 16),
              ],
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

  // ================= MOCK DATA DIPERBAIKI =================
  PurchaseReceipt _generateMockReceipt() {
    return PurchaseReceipt(
      id: 1,
      title: 'Mock Product',
      price: 1225,
      description: 'Mock receipt',
      category: 'Purchase',
      image: '',
      rating: 0,
      ratingCount: 0,
      orderId: orderId,
      orderDate: '31 Des 2023 10:00:00',
      customerName: 'Noraj Rayhan',
      customerEmail: 'rayhan@email.com',
      customerPhone: '08123456789',
      shippingAddress: 'Jl. Merdeka No. 123, Komplek Kenanga Blok B No. 5, Jakarta Selatan 12780',
      items: const [
        {'product_name': 'Hoodie Katun', 'quantity': 1, 'price': 500.0, 'product_id': 'h1'},
        {'product_name': 'Sepatu Lari X', 'quantity': 2, 'price': 300.0, 'product_id': 's2'},
      ],
      subtotal: 1100,
      tax: 25,
      discount: 0,
      // HAPUS BARIS INI KARENA SUDAH TIDAK ADA DI CONSTRUCTOR: shippingCost: 100,
      totalAmount: 1225,
      paymentMethod: 'Transfer Bank',
      paymentStatus: 'Success',
      purchaseStructure: 'Pembayaran Penuh',
      installmentMonths: 0,
      installmentAmount: 0,
      selectedShippingOption: ShippingOption(
        // PASTIKAN FIELD YANG DI-REQUIRE DI SHIPPING OPTION TERPENUHI
        id: 'JNT01', // Tambahkan id
        courierName: 'J&T Express',
        name: 'REG',
        serviceType: 'Reguler', // Tambahkan serviceType
        cost: 100,
        estimate: '3-5 hari',
      ),
    );
  }
}