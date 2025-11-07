import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';

import '../model/product.dart';
import '../bloc/cart_cubit.dart';
import '../bloc/product_cubit.dart';
import 'theme_page.dart';

class DetailPage extends StatefulWidget {
  final String productId;
  const DetailPage({super.key, required this.productId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  double userRating = 0;
  int? lastLoadedId;

  @override
  void initState() {
    super.initState();
    _fetchProductData();
  }

  Future<void> _fetchProductData() async {
    final int productId = int.tryParse(widget.productId) ?? 0;
    if (productId == 0) return;
    context.read<ProductCubit>().fetchProductById(productId);
  }

  Future<void> _loadRating(int id) async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userRating = prefs.getDouble('rating_$id') ?? 0;
    });
  }

  Future<void> _saveRating(int id, double rating) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('rating_$id', rating);
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

    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        final product = state.selectedProduct;

        if (product != null && lastLoadedId != product.id) {
          lastLoadedId = product.id;
          _loadRating(product.id);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(product?.title ?? "Memuat..."),
            actions: [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      size: 28, // ✅ ikon diperbesar
                    ),
                    onPressed: () {
                      context.push('/cart');
                    },
                  ),
                  BlocBuilder<CartCubit, CartState>(
                    builder: (context, state) {
                      if (state.items.isEmpty) return const SizedBox.shrink();
                      return Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Center(
                            child: Text(
                              '${state.items.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10, // ✅ ukuran teks diperkecil
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          body: Builder(
            builder: (context) {
              if (state.error != null) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(5.w),
                    child: Text(
                      'Gagal memuat produk.\nError: ${state.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                );
              }

              if (state.loadingSelected || product == null) {
                return Center(
                  child: CircularProgressIndicator(color: theme.primaryColor),
                );
              }

              return SingleChildScrollView(
                padding: EdgeInsets.all(5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.network(
                        product.image,
                        height: 28.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      product.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    Text(
                      formatRupiah(product.price),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 2.5.h),
                    Text(
                      "Beri Rating:",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: List.generate(5, (i) {
                        return IconButton(
                          icon: Icon(
                            i < userRating ? Icons.star : Icons.star_border,
                            color: AppTheme.secondaryColor,
                            size: 30,
                          ),
                          onPressed: () {
                            setState(() => userRating = i + 1.0);
                            _saveRating(product.id, userRating);
                          },
                        );
                      }),
                    ),
                    SizedBox(height: 2.5.h),
                    Text(
                      "Deskripsi:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      product.description,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.all(4.w),
            child: ElevatedButton.icon(
              style: theme.elevatedButtonTheme.style?.copyWith(
                minimumSize:
                    WidgetStateProperty.all(Size(double.infinity, 6.h)),
              ),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text(
                "Tambah ke Keranjang",
                style: TextStyle(fontSize: 16),
              ),
              onPressed: product == null
                  ? null
                  : () {
                      context.read<CartCubit>().add(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text("${product.title} ditambahkan ke keranjang"),
                          backgroundColor: AppTheme.secondaryColor,
                        ),
                      );
                    },
            ),
          ),
        );
      },
    );
  }
}
