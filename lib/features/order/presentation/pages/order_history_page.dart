import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/order/domain/entities/purchase_receipt.dart';
import 'package:ecommerce/app/theme/app_theme.dart';
import 'package:ecommerce/features/cart/presentation/cubits/cart_cubit.dart';
import 'package:ecommerce/features/settings/data/notification_service.dart';

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

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJsonList = prefs.getStringList('purchase_history') ?? [];

    final loadedHistory = historyJsonList.map((jsonString) {
      final receiptMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return PurchaseReceipt.fromJson(receiptMap);
    }).toList();

    if (mounted) {
      setState(() {
        history = loadedHistory
            .where(
              (e) =>
                  e.paymentStatus.toLowerCase() == 'success' ||
                  e.paymentStatus.toLowerCase() == 'done',
            )
            .toList();
        isLoading = false;
      });
    }
  }

  Future<void> _saveReview(
    String productId,
    double rating,
    String text,
    PurchaseReceipt receipt,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('product_reviews') ?? '{}';
    Map<String, dynamic> map = {};
    try {
      map = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      map = {};
    }

    final List<dynamic> list = List<dynamic>.from(map[productId] ?? []);
    list.add({
      'rating': rating,
      'text': text,
      'orderId': receipt.orderId,
      'orderDate': receipt.orderDate,
    });
    map[productId] = list;

    await prefs.setString('product_reviews', jsonEncode(map));

    if (mounted) {
      await NotificationService.showIfEnabledDialog(
        context,
        title: 'Ulasan',
        body: 'Ulasan berhasil disimpan',
      );
    }
  }

  void _showReviewDialog(
    BuildContext context,
    String productId,
    String productName,
    PurchaseReceipt receipt,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) {
        double selectedRating = 5.0;
        final TextEditingController controller = TextEditingController();
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: Text('Ulas $productName'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        return IconButton(
                          icon: Icon(
                            i < selectedRating ? Icons.star : Icons.star_border,
                            color: AppTheme.secondaryColor,
                          ),
                          onPressed: () =>
                              setStateSB(() => selectedRating = i + 1.0),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Tulis ulasan Anda (opsional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _saveReview(
                      productId,
                      selectedRating,
                      controller.text.trim(),
                      receipt,
                    );
                    if (mounted) Navigator.of(context).pop();
                  },
                  child: const Text('Kirim'),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text(
          'Order History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
          ? const Center(child: Text('Tidak ada pesanan selesai'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                return _orderCard(context, history[index]);
              },
            ),
    );
  }

  // ================= CARD =================
  Widget _orderCard(BuildContext context, PurchaseReceipt receipt) {
    // Extract all items info
    List<Map<String, dynamic>> productsList = [];

    try {
      if (receipt.items.isNotEmpty) {
        for (var item in receipt.items) {
          if (item is Map<String, dynamic>) {
            final itemMap = item;
            productsList.add({
              'product_id':
                  (itemMap['product_id'] ?? itemMap['productId'] ?? '')
                      .toString(),
              'product_image':
                  (itemMap['product_image'] ?? itemMap['productImage'] ?? '')
                      .toString()
                      .trim(),
              'product_name':
                  (itemMap['product_name'] ??
                          itemMap['productName'] ??
                          'Produk')
                      .toString()
                      .trim(),
              'quantity': itemMap['quantity'] ?? 1,
              'price': (itemMap['price'] ?? 0).toDouble(),
            });
          }
        }
      }
    } catch (e) {
      print('Error extracting product info: $e');
      print('Items content: ${receipt.items}');
    }

    print('DEBUG: Total items = ${productsList.length}');

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        double screenWidth = MediaQuery.of(context).size.width;
        // compute item thumbnail size based on available width
        final double itemSize = math.min(80, math.max(56, width * 0.16));
        final double itemTextWidth =
            itemSize; // use for the label beneath thumbnail

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color:
                    (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black)
                        .withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Items horizontal scroll atau list
              SizedBox(
                height: itemSize + 36,
                child: productsList.isEmpty
                    ? const Center(child: Text('Tidak ada barang'))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: productsList.length,
                        itemBuilder: (context, index) {
                          final product = productsList[index];
                          final imageUrl = (product['product_image'] ?? '')
                              .toString();
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: itemSize,
                                  height: itemSize,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF303030)
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                    image: imageUrl.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(imageUrl),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: imageUrl.isEmpty
                                      ? const Icon(
                                          Icons.image,
                                          size: 28,
                                          color: Colors.grey,
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width: itemTextWidth,
                                  child: Text(
                                    '${product['product_name']} (x${product['quantity']})',
                                    style: TextStyle(
                                      fontSize: math.max(10, itemSize * 0.12),
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimaryColor,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width: itemTextWidth,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      final pid = (product['product_id'] ?? '')
                                          .toString();
                                      _showReviewDialog(
                                        context,
                                        pid,
                                        product['product_name']?.toString() ??
                                            'Produk',
                                        receipt,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.rate_review,
                                      size: 16,
                                    ),
                                    label: const Text(
                                      'Ulas',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),

              // Total dan buttons
              Text(
                formatRupiah(receipt.totalAmount),
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: (screenWidth * 0.045).clamp(14, 20),
                ),
              ),

              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        // Add items kembali ke cart
                        try {
                          for (var item in receipt.items) {
                            if (item is Map<String, dynamic>) {
                              final productId = (item['product_id'] ?? '')
                                  .toString();
                              final productName = (item['product_name'] ?? '')
                                  .toString();
                              final productImage = (item['product_image'] ?? '')
                                  .toString();
                              final quantity =
                                  int.tryParse(
                                    (item['quantity'] ?? 1).toString(),
                                  ) ??
                                  1;
                              final price =
                                  double.tryParse(
                                    (item['price'] ?? 0).toString(),
                                  ) ??
                                  0.0;

                              context.read<CartCubit>().addItem(
                                productId: productId,
                                productName: productName,
                                productImage: productImage,
                                quantity: quantity,
                                price: price,
                              );
                            }
                          }

                          // Show success message
                          if (context.mounted) {
                            await NotificationService.showIfEnabledDialog(
                              context,
                              title: 'Berhasil',
                              body:
                                  '${receipt.items.length} produk ditambahkan ke cart',
                            );

                            // Navigate to cart after short delay
                            Future.delayed(
                              const Duration(milliseconds: 500),
                              () {
                                if (context.mounted) {
                                  context.go('/cart');
                                }
                              },
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            await NotificationService.showIfEnabledDialog(
                              context,
                              title: 'Error',
                              body: e.toString(),
                            );
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: BorderSide(color: AppTheme.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Pesan Lagi',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.go(
                          '/purchase-receipt/${receipt.orderId}',
                          extra: receipt.toJson(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Lihat Pemesanan',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
