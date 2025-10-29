// cart_page.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../model/cart.dart'; // 💡 Pastikan path model benar
import 'theme_page.dart'; 

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  // ✅ Format harga ke Rupiah
  String formatRupiah(double price) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(price);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);
    final theme = Theme.of(context); // ✅ Panggil tema

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Text(
                'Keranjang masih kosong 🛍️',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final entry = cart.items.entries.elementAt(index);
                final product = entry.key;
                final qty = entry.value;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)), // ✅ Ganti
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Image.network(
                      product.image,
                      width: 60,
                      fit: BoxFit.contain,
                    ),
                    title: Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      formatRupiah(product.price * qty),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline, color: AppTheme.primaryColor), // ✅ Ganti
                          onPressed: () => cart.decrease(product),
                        ),
                        Text('$qty', style: const TextStyle(fontSize: 16)),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline, color: AppTheme.secondaryColor), // ✅ Ganti
                          onPressed: () => cart.add(product),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${formatRupiah(cart.totalPrice)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor, // ✅ Ganti
                    ),
                  ),
                  ElevatedButton(
                    style: theme.elevatedButtonTheme.style, // ✅ Ganti
                    onPressed: () =>
                        Navigator.pushNamed(context, '/payment', arguments: cart.totalPrice),
                    child: const Text('Checkout'),
                  ),
                ],
              ),
            ),
    );
  }
}