import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:ecommerce/features/order/domain/entities/purchase_receipt.dart';
import 'package:ecommerce/app/theme/app_theme.dart'; // <- pastikan path sesuai

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
    final receipt = receiptData != null
        ? PurchaseReceipt.fromJson(receiptData!)
        : _generateMockReceipt();
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = constraints.maxWidth;
            final double cardWidth = maxWidth > 600 ? 420.0 : maxWidth * 0.92;

            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.backgroundColor,
                        const Color(0xFFFFFFFF),
                      ],
                    ),
                  ),
                ),
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
              ],
            );
          },
        ),
      ),
    );
  }

  // ================= UI CARD =================

  Widget _receiptCard(BuildContext context, PurchaseReceipt receipt) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color:
                (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black)
                    .withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          SizedBox(height: 8),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 32),
          ),
          SizedBox(height: 12),
          Text(
            "Struk Pembelian",
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor),
          ),
          SizedBox(height: 6),
          Text(
            currency.format(receipt.totalAmount),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          SizedBox(height: 14),
          _detailRow("Tanggal", receipt.orderDate),
          _detailRow("Metode Pembayaran", receipt.paymentMethod),
          _detailRow("No Referensi", receipt.orderId),
          _detailRow("Account", receipt.customerName),
          Divider(height: 28, color: Theme.of(context).dividerColor),
          if (receipt.items.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              "Item yang Dibeli:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 8),
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
                    SizedBox(width: 8),
                    Flexible(
                      flex: 0,
                      child: Text(
                        currency.format(price * qty),
                        style: TextStyle(
                          color: AppTheme.textPrimaryColor,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            Divider(height: 16, color: Theme.of(context).dividerColor),
          ],
          _detailRow(
            "Total",
            currency.format(receipt.totalAmount),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
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
              foregroundColor: AppTheme.primaryColor,
              side: BorderSide(color: AppTheme.secondaryColor),
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
            child: const Text("Kembali ke Dashboard"),
          ),
        ),
      ],
    );
  }

  // ================= PDF =================

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
      orderDate: '31 Dec 2023',
      customerName: 'Noraj',
      customerEmail: 'rayhan@email.com',
      customerPhone: '08123456789',
      shippingAddress: 'Jl. Merdeka No. 123',
      items: const [],
      subtotal: 1200,
      shippingCost: 0,
      tax: 25,
      discount: 0,
      totalAmount: 1225,
      paymentMethod: 'QRIS',
      paymentStatus: 'Success',
      purchaseStructure: 'Residential',
      installmentMonths: 0,
      installmentAmount: 0,
    );
  }
}
