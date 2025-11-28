import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:ecommerce/features/cart/presentation/cubits/cart_cubit.dart';
import 'package:ecommerce/features/product/presentation/cubits/product_cubit.dart';
import 'package:ecommerce/app/theme/app_theme.dart';

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
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        final product = state.selectedProduct;

        if (product != null && lastLoadedId != product.id) {
          lastLoadedId = product.id;
          _loadRating(product.id);
        }

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go('/dashboard'),
            ),
            title: Text(
              product?.title ?? "Memuat...",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: () => context.go('/cart'),
                  ),
                  BlocBuilder<CartCubit, CartState>(
                    builder: (context, state) {
                      if (state.items.isEmpty) return const SizedBox.shrink();
                      return Positioned(
                        right: 8,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${state.items.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
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
                    padding: const EdgeInsets.all(24.0),
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
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final double width = constraints.maxWidth;
                  final bool isMobile = width < 600;
                  final bool isTablet = width >= 600 && width < 1024;
                  final bool isDesktop = width >= 1024;

                  final double outerPaddingH = isMobile
                      ? 16.0
                      : (isTablet ? 32.0 : 48.0);
                  final double outerPaddingV = isMobile
                      ? 12.0
                      : (isTablet ? 24.0 : 32.0);
                  final double imageWidth = isMobile
                      ? width * 0.8
                      : (isTablet ? 320.0 : 400.0);
                  final double imageHeight = isMobile
                      ? width * 0.5
                      : (isTablet ? 220.0 : 300.0);
                  final double thumbSize = isMobile
                      ? 48.0
                      : (isTablet ? 64.0 : 72.0);

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: outerPaddingH,
                      vertical: outerPaddingV,
                    ),
                    child: Flex(
                      direction: isDesktop ? Axis.horizontal : Axis.vertical,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ---------- Left: Product Image ----------
                        if (!isDesktop) ...[
                          Column(
                            children: [
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      product.image,
                                      height: imageHeight,
                                      width: imageWidth,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  3,
                                  (index) => Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    width: thumbSize,
                                    height: thumbSize,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppTheme.secondaryColor,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: NetworkImage(product.image),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Flexible(
                            flex: 5,
                            child: Column(
                              children: [
                                Center(
                                  child: Container(
                                    width: imageWidth,
                                    height: imageHeight,
                                    decoration: BoxDecoration(
                                      color: AppTheme.cardColor,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              (Theme.of(context).brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black)
                                                  .withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        product.image,
                                        width: imageWidth,
                                        height: imageHeight,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    3,
                                    (index) => Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      width: thumbSize,
                                      height: thumbSize,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppTheme.secondaryColor,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: NetworkImage(product.image),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        if (isDesktop)
                          SizedBox(width: 32.0)
                        else
                          SizedBox(height: 32.0),

                        // ---------- Right: Product Info ----------
                        Expanded(
                          flex: isDesktop ? 5 : 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "",
                                style: TextStyle(
                                  color: AppTheme.secondaryColor,
                                  fontSize: isMobile
                                      ? 14
                                      : (isTablet ? 16 : 18),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                product.title,
                                style: TextStyle(
                                  fontSize: isMobile
                                      ? 20
                                      : (isTablet ? 24 : 28),
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                              SizedBox(height: 12.0),
                              Row(
                                children: [
                                  Text(
                                    formatRupiah(product.price),
                                    style: TextStyle(
                                      fontSize: isMobile
                                          ? 18
                                          : (isTablet ? 20 : 22),
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  SizedBox(width: 16.0),
                                  Text(
                                    "Rp ${(product.price * 1.1).toStringAsFixed(0)}",
                                    style: TextStyle(
                                      fontSize: isMobile
                                          ? 14
                                          : (isTablet ? 16 : 18),
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  SizedBox(width: 8.0),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.secondaryColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      "15% OFF",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.0),

                              // Rating
                              Wrap(
                                children: List.generate(5, (i) {
                                  return IconButton(
                                    icon: Icon(
                                      i < userRating
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: AppTheme.secondaryColor,
                                      size: isMobile
                                          ? 24
                                          : (isTablet ? 28 : 32),
                                    ),
                                    onPressed: () {
                                      setState(() => userRating = i + 1.0);
                                      _saveRating(product.id, userRating);
                                    },
                                  );
                                }),
                              ),

                              SizedBox(height: 16.0),
                              Text(
                                product.description,
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                  fontSize: isMobile
                                      ? 14
                                      : (isTablet ? 16 : 18),
                                  height: 1.5,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                              SizedBox(height: 24.0),

                              // Quantity selector + Add to Cart
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppTheme.secondaryColor,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          color: AppTheme.primaryColor,
                                          onPressed: () {},
                                        ),
                                        const Text(
                                          "1",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          color: AppTheme.primaryColor,
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 24.0),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        context.read<CartCubit>().add(product);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Ditambahkan ke keranjang!',
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryColor,
                                        padding: EdgeInsets.symmetric(
                                          vertical: isMobile
                                              ? 14.0
                                              : (isTablet ? 18.0 : 22.0),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        "ADD TO CART",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.0),

                              Row(
                                children: [
                                  Icon(
                                    Icons.credit_card,
                                    color: AppTheme.secondaryColor,
                                    size: isMobile ? 18 : (isTablet ? 20 : 22),
                                  ),
                                  SizedBox(width: 12.0),
                                  const Text(
                                    "Kami menerima semua metode pembayaran",
                                    style: TextStyle(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.0),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
