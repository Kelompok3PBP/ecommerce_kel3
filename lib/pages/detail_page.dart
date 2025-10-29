// detail_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';
import '../model/product.dart'; // 💡 Pastikan path model benar
import '../model/cart.dart'; // 💡 Pastikan path model benar
import 'theme_page.dart'; // ✅ Tambahkan ini

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
    final cart = Provider.of<CartModel>(context, listen: false);
    final theme = Theme.of(context); // ✅ Panggil tema

    return Scaffold(
      appBar: AppBar(
        title: Text(isTranslating ? "Memuat..." : translatedTitle),
        // ✅ Warna otomatis dari tema
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                widget.product.image,
                height: 220,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 25),
            Text(
              translatedTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor, // ✅ Ganti
              ),
            ),
            if (isTranslating)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(color: AppTheme.primaryColor), // ✅ Ganti
              ),
            const SizedBox(height: 10),
            Chip(
              label: Text(
                translateCategory(widget.product.category),
                style: TextStyle(color: AppTheme.textPrimaryColor), // ✅ Ganti
              ),
              backgroundColor: AppTheme.secondaryColor.withOpacity(0.4), // ✅ Ganti
            ),
            const SizedBox(height: 10),
            Text(
              formatRupiah(widget.product.price),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor, // ✅ Ganti
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Beri Rating:",
              style: TextStyle(fontSize: 16, color: AppTheme.textPrimaryColor), // ✅ Ganti
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < userRating ? Icons.star : Icons.star_border,
                    color: AppTheme.secondaryColor, // ✅ Ganti
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() => userRating = index + 1.0);
                    _saveRating(userRating);
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
            Text(
              "Deskripsi:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor, // ✅ Ganti
              ),
            ),
            const SizedBox(height: 8),
            Text(
              translatedDescription,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                color: AppTheme.textSecondaryColor, // ✅ Ganti
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          style: theme.elevatedButtonTheme.style?.copyWith( // ✅ Ganti
             minimumSize: MaterialStateProperty.all(const Size(double.infinity, 50)),
          ),
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text(
            "Tambah ke Keranjang",
            style: TextStyle(fontSize: 18),
          ),
          onPressed: () {
            cart.add(widget.product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("${widget.product.title} ditambahkan"),
                backgroundColor: AppTheme.secondaryColor, // ✅ Ganti
              ),
            );
          },
        ),
      ),
    );
  }
}