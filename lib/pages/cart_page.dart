import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../model/cart.dart';
import '../model/product.dart';
import '../pages/payment_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  // Format harga ke Rupiah
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
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Text(
                'Keranjang masih kosong 🛍️',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: cart.items.entries.map((entry) {
                final Product product = entry.key;
                final int qty = entry.value;

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.shopping_bag,
                              size: 50,
                              color: Colors.purple,
                            ),
                      ),
                    ),
                    title: Text(
                      product.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatDollar(product.price),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          product.category,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 130,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.purple,
                            ),
                            onPressed: () {
                              cart.decrease(product);
                            },
                          ),
                          Text(
                            '$qty',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.purple,
                            ),
                            onPressed: () {
                              cart.add(product);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

      // Bagian bawah: total harga & tombol checkout
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: ${formatDollar(cart.totalPrice)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: cart.items.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PaymentPage(total: cart.totalPrice),
                        ),
                      );
                    },
              child: const Text(
                'Checkout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
