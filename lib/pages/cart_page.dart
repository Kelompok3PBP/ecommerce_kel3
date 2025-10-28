import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../model/cart.dart';


class CartPage extends StatelessWidget {
  const CartPage({super.key});

  // ✅ Fungsi format harga diubah ke Rupiah
  String formatRupiah(double price) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(price);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang Belanja')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Keranjang masih kosong 🛍️', style: TextStyle(fontSize: 18)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final entry = cart.items.entries.elementAt(index);
                final product = entry.key;
                final qty = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Image.network(product.image, width: 60, fit: BoxFit.contain),
                    title: Text(product.title, maxLines: 2),
                    subtitle: Text(formatRupiah(product.price * qty)), // Harga total per item
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => cart.decrease(product)),
                        Text('$qty', style: const TextStyle(fontSize: 16)),
                        IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.green), onPressed: () => cart.add(product)),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.items.isEmpty ? null : Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, -2))]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total: ${formatRupiah(cart.totalPrice)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/payment', arguments: cart.totalPrice),
              child: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}