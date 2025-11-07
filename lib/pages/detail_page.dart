import 'package:flutter/material.dart'; // <--- FIKS
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';
import 'package:sizer/sizer.dart';
import '../model/product.dart';
import '../bloc/cart_cubit.dart';
import 'theme_page.dart';
import 'cart_page.dart';

class DetailPage extends StatefulWidget {
  final Product product;
  const DetailPage({super.key, required this.product});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  double userRating = 0;
  String translatedTitle = "";
  String translatedDescription = "";
  bool isTranslating = true;

  @override
  void initState() {
    super.initState();
    _loadRating();
    _translateProductDetails();
  }

  Future<void> _translateProductDetails() async {
    setState(() {
      translatedTitle = widget.product.title;
      translatedDescription = widget.product.description;
    });
    try {
      final translator = GoogleTranslator();
      var titleTranslation = await translator.translate(
        widget.product.title,
        from: 'en',
        to: 'id',
      );
      var descTranslation = await translator.translate(
        widget.product.description,
        from: 'en',
        to: 'id',
      );
      if (mounted) {
        setState(() {
          translatedTitle = titleTranslation.text;
          translatedDescription = descTranslation.text;
        });
      }
    } catch (e) {
      print("Gagal menerjemahkan: $e");
    } finally {
      if (mounted) {
        setState(() {
          isTranslating = false;
        });
      }
    }
  }

  String translateCategory(String category) {
    switch (category.toLowerCase()) {
      case "electronics":
        return "Elektronik";
      case "jewelery":
        return "Perhiasan";
      case "men's clothing":
        return "Pakaian Pria";
      case "women's clothing":
        return "Pakaian Wanita";
      default:
        return category;
    }
  }

  Future<void> _loadRating() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRating = prefs.getDouble('rating_${widget.product.id}') ?? 0;
    });
  }

  Future<void> _saveRating(double rating) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('rating_${widget.product.id}', rating);
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
      appBar: AppBar(
        title: Text(isTranslating ? "Memuat..." : translatedTitle),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartPage()),
                  );
                },
              ),
              BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  if (state.items.isEmpty) return const SizedBox.shrink();
                  return Positioned(
                    right: 6,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(1.w),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${state.items.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.sp,
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
      
      body: Center( // <-- PERBAIKAN ADAPTIF
        child: ConstrainedBox( // <-- PERBAIKAN ADAPTIF
          constraints: const BoxConstraints(
            maxWidth: 900, 
          ),
          child: SingleChildScrollView( 
            padding: EdgeInsets.all(5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.network(
                    widget.product.image,
                    height: 28.h,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  translatedTitle,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                if (isTranslating)
                  Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: LinearProgressIndicator(color: AppTheme.primaryColor),
                  ),
                SizedBox(height: 1.5.h),
                Chip(
                  label: Text(
                    translateCategory(widget.product.category),
                    style: TextStyle(color: AppTheme.textPrimaryColor, fontSize: 11.sp),
                  ),
                  backgroundColor: AppTheme.secondaryColor.withOpacity(0.4),
                ),
                SizedBox(height: 1.5.h),
                Text(
                  formatRupiah(widget.product.price),
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(height: 2.5.h),
                Text(
                  "Beri Rating:",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppTheme.textPrimaryColor
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < userRating ? Icons.star : Icons.star_border,
                        color: AppTheme.secondaryColor,
                        size: 28.sp, // <-- PERBAIKAN .dp KE .sp
                      ),
                      onPressed: () {
                        setState(() => userRating = index + 1.0);
                        _saveRating(userRating);
                      },
                    );
                  }),
                ),
                SizedBox(height: 2.5.h),
                Text(
                  "Deskripsi:",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  translatedDescription,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.4,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(4.w),
        child: ElevatedButton.icon(
          style: theme.elevatedButtonTheme.style?.copyWith(
            minimumSize: WidgetStateProperty.all(
              Size(double.infinity, 6.h),
            ),
          ),
          icon: const Icon(Icons.add_shopping_cart),
          label: Text(
            "Tambah ke Keranjang",
            style: TextStyle(fontSize: 14.sp),
          ),
          onPressed: () {
            context.read<CartCubit>().add(widget.product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "${widget.product.title} ditambahkan ke keranjang",
                ),
                backgroundColor: AppTheme.secondaryColor,
              ),
            );
          },
        ),
      ),
    );
  }
}