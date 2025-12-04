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
  final ValueNotifier<List<PurchaseReceipt>> history = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(true);

  Color _getTextPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.onBackground;
  }

  Color _getTextSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  Color _getCardColor(BuildContext context) {
    return Theme.of(context).cardColor;
  }

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
      history.value = loadedHistory
          .where(
            (e) =>
                e.paymentStatus.toLowerCase() == 'success' ||
                e.paymentStatus.toLowerCase() == 'done',
          )
          .toList();
      isLoading.value = false;
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
    final theme = Theme.of(context);
    final textPrimaryColor = _getTextPrimaryColor(context);

    showDialog<void>(
      context: context,
      builder: (context) {
        final selectedRating = ValueNotifier<double>(5.0);
        final TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Text('Ulas $productName'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<double>(
                  valueListenable: selectedRating,
                  builder: (context, rating, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        return IconButton(
                          icon: Icon(
                            i < rating ? Icons.star : Icons.star_border,
                            color: AppTheme.secondaryColor,
                          ),
                          onPressed: () => selectedRating.value = i + 1.0,
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Tulis ulasan Anda (opsional)',
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: theme.colorScheme.primary),
                    ),
                    hintStyle: TextStyle(color: theme.hintColor),
                  ),
                  style: TextStyle(color: textPrimaryColor),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                selectedRating.dispose();
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _saveReview(
                  productId,
                  selectedRating.value,
                  controller.text.trim(),
                  receipt,
                );
                selectedRating.dispose();
                if (mounted) Navigator.of(context).pop();
              },
              child: const Text('Kirim'),
            ),
          ],
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
      body: ValueListenableBuilder<bool>(
        valueListenable: isLoading,
        builder: (context, loading, _) {
          if (loading)
            return Center(
              child: CircularProgressIndicator(color: theme.primaryColor),
            );
          return ValueListenableBuilder<List<PurchaseReceipt>>(
            valueListenable: history,
            builder: (context, list, __) {
              if (list.isEmpty) {
                return Center(
                  child: Text(
                    'Tidak ada pesanan selesai',
                    style: TextStyle(color: _getTextPrimaryColor(context)),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return _orderCard(context, list[index]);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _orderCard(BuildContext context, PurchaseReceipt receipt) {
    final theme = Theme.of(context);
    final textPrimaryColor = _getTextPrimaryColor(context);
    final textSecondaryColor = _getTextSecondaryColor(context);
    final cardColor = _getCardColor(context);

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
    } catch (e) {}

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        double screenWidth = MediaQuery.of(context).size.width;
        final double itemSize = math.min(80, math.max(56, width * 0.16));

        final productRepresentative = productsList.isNotEmpty
            ? productsList.first
            : null;
        final bool isReviewed = false;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: textPrimaryColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (productRepresentative != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: itemSize,
                      height: itemSize,
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF303030)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        image: productRepresentative['product_image'].isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(
                                  productRepresentative['product_image'],
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: productRepresentative['product_image'].isEmpty
                          ? const Icon(
                              Icons.image,
                              size: 28,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  '${productRepresentative['product_name']} (x${productRepresentative['quantity']})',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimaryColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              if (!isReviewed)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryColor.withOpacity(
                                      0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppTheme.secondaryColor
                                          .withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      final pid =
                                          productRepresentative['product_id']
                                              .toString();
                                      _showReviewDialog(
                                        context,
                                        pid,
                                        productRepresentative['product_name']
                                            .toString(),
                                        receipt,
                                      );
                                    },
                                    child: Text(
                                      'Ulas',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.secondaryColor,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    'Sudah Diulas',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textSecondaryColor.withOpacity(
                                        0.6,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          Text(
                            'Status Pengiriman: Selesai',
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondaryColor,
                            ),
                          ),

                          const SizedBox(height: 8),
                          Text(
                            formatRupiah(receipt.totalAmount),
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Center(
                  child: Text(
                    'Tidak ada barang',
                    style: TextStyle(color: textPrimaryColor),
                  ),
                ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
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

                          if (context.mounted) {
                            await NotificationService.showIfEnabledDialog(
                              context,
                              title: 'Berhasil',
                              body:
                                  '${receipt.items.length} produk ditambahkan ke cart',
                            );
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
