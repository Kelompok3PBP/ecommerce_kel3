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

  // --- Helper untuk Warna Adaptif ---
  Color _getTextPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.onBackground;
  }

  Color _getTextSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }
  // ----------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Pastikan kita mendapatkan data pengiriman dari receiptData
    final receipt = receiptData != null
        ? PurchaseReceipt.fromJson(receiptData!)
        : _generateMockReceipt(); 

    return Scaffold(
      // 💡 Menggunakan scaffoldBackgroundColor dari tema
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = constraints.maxWidth;
            final double cardWidth = maxWidth > 600 ? 420.0 : maxWidth * 0.92;

            return Stack(
              children: [
                // Container background dihilangkan, cukup pakai Scaffold.backgroundColor
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
                    icon: Icon(
                      Icons.close, 
                      // 💡 Menggunakan warna teks primary adaptif
                      color: _getTextPrimaryColor(context),
                    ),
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
    final textSecondaryColor = _getTextSecondaryColor(context);
    final cardColor = Theme.of(context).cardColor; // Mengambil cardColor adaptif
    final shippingOption = receipt.selectedShippingOption;
    final shippingCostDisplay = currency.format(receipt.shippingCost);

    return Container(
      decoration: BoxDecoration(
        // 💡 Menggunakan cardColor dari tema
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        // Border utama tetap primaryColor
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
          // Penggunaan _detailRow akan mengontrol warna teks adaptif
          _detailRow(context, "Tanggal", receipt.orderDate),
          const SizedBox(height: 8),
          _detailRow(context, "Metode Pembayaran", receipt.paymentMethod),
          const SizedBox(height: 8),
          _detailRow(context, "No Referensi", receipt.orderId),
          const SizedBox(height: 8),
          _detailRow(context, "Account", receipt.customerName),
          const SizedBox(height: 16),
          // --- DETAIL PENGIRIMAN ---
          Container(
            // 💡 Menggunakan warna adaptif dengan opacity
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.05,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor, width: 1.5),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "📦 Detail Pengiriman",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                _detailRow(
                  context,
                  "Kurir",
                  shippingOption?.courierName ?? "Tidak Dipilih",
                ),
                const SizedBox(height: 6),
                _detailRow(context, "Layanan", shippingOption?.name ?? "-"),
                const SizedBox(height: 6),
                _detailRow(context, "Estimasi", shippingOption?.estimate ?? "-"),
                const SizedBox(height: 6),
                _detailRow(context, "Biaya Kirim", shippingCostDisplay, isBold: true),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  // 💡 Menggunakan warna kontainer alamat yang adaptif
                  decoration: BoxDecoration(
                    color: (Theme.of(context).brightness == Brightness.dark
                            ? Colors.blue.shade900
                            : Colors.blue)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "📍 ${receipt.shippingAddress}",
                    style: TextStyle(
                      fontSize: 12,
                      // 💡 Menggunakan warna teks secondary adaptif
                      color: textSecondaryColor,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // --------------------------
          const Divider(height: 2, color: AppTheme.primaryColor, thickness: 2),
          const SizedBox(height: 16),
          // Item yang Dibeli
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
                          // 💡 Menggunakan warna teks secondary adaptif
                          color: textSecondaryColor,
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
            const Divider(
              height: 2,
              color: AppTheme.primaryColor,
              thickness: 1,
            ),
            const SizedBox(height: 12),
          ],
          _detailRow(
            context,
            "Subtotal Produk",
            currency.format(receipt.subtotal),
            isBold: true,
          ),
          const SizedBox(height: 8),
          _detailRow(context, "Biaya Kirim", shippingCostDisplay, isBold: true),
          const SizedBox(height: 8),
          _detailRow(
            context,
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
    BuildContext context, // Tambahkan context
    String label,
    String value, {
    bool isBold = false,
    bool isPrimary = false,
    bool isMultiline = false,
  }) {
    final textPrimaryColor = _getTextPrimaryColor(context);
    final textSecondaryColor = _getTextSecondaryColor(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                // 💡 Menggunakan warna teks secondary adaptif, kecuali jika isPrimary
                color: isPrimary
                    ? AppTheme.primaryColor
                    : textSecondaryColor,
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
                // 💡 Menggunakan warna teks primary adaptif, kecuali jika isPrimary
                color: isPrimary
                    ? AppTheme.primaryColor
                    : textPrimaryColor,
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
    final theme = Theme.of(context);
    
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _downloadPDF(receipt),
            icon: const Icon(Icons.download),
            label: const Text("Download PDF"),
            style: OutlinedButton.styleFrom(
              // Foreground dan side tetap karena latar belakangnya primaryColor
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
              // 💡 Latar belakang tombol ini menjadi adaptif: cardColor
              backgroundColor: theme.cardColor,
              // 💡 Foreground tombol ini menjadi adaptif: primaryColor
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

  // ================= PDF (Tidak perlu diubah untuk Dark Mode UI) =================

  Future<void> _downloadPDF(PurchaseReceipt receipt) async {
    final pdf = pw.Document();

    // Ambil detail ShippingOption untuk PDF
    final shippingOption = receipt.selectedShippingOption;

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
              pw.SizedBox(height: 12),
              // Detail Pengiriman
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(4),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "DETAIL PENGIRIMAN",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    _pdfRow(
                      "Kurir",
                      shippingOption?.courierName ?? "Tidak Dipilih",
                    ),
                    _pdfRow("Layanan", shippingOption?.name ?? "-"),
                    _pdfRow("Estimasi", shippingOption?.estimate ?? "-"),
                    _pdfRow(
                      "Biaya",
                      currency.format(shippingOption?.cost ?? 0),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      receipt.shippingAddress,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
              // --------------------------
              pw.SizedBox(height: 10),
              pw.Divider(),
              _pdfRow("Subtotal Produk", currency.format(receipt.subtotal)),
              _pdfRow("Biaya Kirim", currency.format(receipt.shippingCost)),
              if (receipt.tax > 0)
                _pdfRow("Pajak", currency.format(receipt.tax)),
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
                  return _pdfRow('$name (x$qty)', currency.format(price * qty));
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
      orderDate: '2025-12-03 21:46:45', // Format tanggal disesuaikan dengan gambar
      customerName: 'admin@mail.com', // Disesuaikan dengan gambar
      customerEmail: 'admin@mail.com', 
      customerPhone: '08123456789',
      shippingAddress:
          'Jl. Merdeka No. 123, Komplek Kenanga Blok B No. 5, Jakarta Selatan 12780',
      items: const [
        // Total subtotal 0 dan total 10.610 dari gambar tidak konsisten
        // Saya menggunakan subtotal 1100 + biaya kirim 10.500 = 11.600
        // Untuk mencocokkan total akhir di gambar (Rp 10.610), saya perlu mengasumsikan
        // bahwa harga di mock data Anda berbeda atau ada diskon 9110.
        // Saya akan menggunakan data mock yang saya buat di bawah ini agar totalnya mendekati 10.610
         {
          'product_name': 'Item Pembelian',
          'quantity': 1,
          'price': 110.0,
          'product_id': 'item1',
        },
      ],
      subtotal: 110, // Disesuaikan agar total 10.610 lebih masuk akal
      tax: 0,
      discount: 0,
      totalAmount: 10610, // Sesuai dengan gambar
      paymentMethod: 'Transfer Bank',
      paymentStatus: 'Success',
      purchaseStructure: 'Pembayaran Penuh',
      installmentMonths: 0,
      installmentAmount: 0,
      selectedShippingOption: ShippingOption(
        id: 'POS01', // Disesuaikan dengan gambar
        courierName: 'POS Indonesia', // Disesuaikan dengan gambar
        name: 'Ekonomi', // Disesuaikan dengan gambar
        serviceType: 'Reguler', 
        cost: 10500, // Disesuaikan dengan gambar
        estimate: '5-7 hari', // Disesuaikan dengan gambar
      ),
    );
  }
}