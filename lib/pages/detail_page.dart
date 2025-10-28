import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/product.dart';
import '../model/cart.dart';

class DetailPage extends StatefulWidget {
  final Product product;

  const DetailPage({super.key, required this.product});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  double userRating = 0;

  @override
  void initState() {
    super.initState();
    _loadRating();
  }

  // Ambil rating dari SharedPreferences
  Future<void> _loadRating() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRating = prefs.getDouble('rating_${widget.product.id}') ?? 0;
    });
  }

  // Simpan rating ke SharedPreferences
  Future<void> _saveRating(double rating) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('rating_${widget.product.id}', rating);
  }

  String formatDollar(double price) {
    final format = NumberFormat.currency(
      locale: 'en_US', // pakai format Amerika (USD)
      symbol: '\$', // tanda $ (pakai backslash biar ga error string)
      decimalDigits: 2, // dollar biasanya pakai 2 angka di belakang koma
    );
    return format.format(price);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);

    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text(
          widget.product.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.pushNamed(context, '/cart'),
              ),
              if (cart.items.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cart.items.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Gambar Produk
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Image.network(
                widget.product.image,
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported,
                  size: 100,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Nama Produk
            Text(
              widget.product.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 10),

            // Kategori
            Chip(
              label: Text(widget.product.category),
              backgroundColor: Colors.purple.shade100,
              labelStyle: const TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Harga
            Text(
              formatDollar(widget.product.price),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Rating interaktif (tersimpan)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < userRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      userRating = index + 1.0;
                    });
                    _saveRating(userRating);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Kamu memberi rating ${index + 1} ⭐"),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 20),

            // Deskripsi produk dari API
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.product.description,
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Tombol Tambah ke Keranjang
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                label: const Text(
                  "Tambah ke Keranjang",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  cart.add(widget.product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green,
                      content: Text(
                        "${widget.product.title} ditambahkan ke keranjang 🛒",
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
