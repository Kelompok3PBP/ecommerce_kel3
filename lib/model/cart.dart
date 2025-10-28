import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'product.dart';

class CartModel extends ChangeNotifier {
  final Map<Product, int> _items = {};

  Map<Product, int> get items => _items;

  double get totalPrice {
    double total = 0;
    _items.forEach((product, qty) {
      total += product.price * qty;
    });
    return total;
  }

  void add(Product product) {
    _items[product] = (_items[product] ?? 0) + 1;
    _saveCart();
    notifyListeners();
  }

  void decrease(Product product) {
    if (_items.containsKey(product)) {
      if (_items[product]! > 1) {
        _items[product] = _items[product]! - 1;
      } else {
        _items.remove(product);
      }
      _saveCart();
      notifyListeners();
    }
  }

  void remove(Product product) {
    _items.remove(product);
    _saveCart();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encoded = _items.entries.map((entry) {
      final product = entry.key;
      final qty = entry.value;
      return jsonEncode({
        'id': product.id,
        'title': product.title,
        'price': product.price,
        'description': product.description,
        'category': product.category,
        'image': product.image,
        'rating': product.rating,
        'ratingCount': product.ratingCount,
        'qty': qty,
      });
    }).toList();
    await prefs.setStringList('cart_items', encoded);
  }

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> data = prefs.getStringList('cart_items') ?? [];

    _items.clear();
    for (var jsonString in data) {
      final jsonData = jsonDecode(jsonString);

      final product = Product(
        id: jsonData['id'] ?? 0,
        title: jsonData['title'] ?? 'Produk Tanpa Nama',
        price: (jsonData['price'] as num).toDouble(),
        description: jsonData['description'] ?? "",
        category: jsonData['category'] ?? "",
        image: jsonData['image'] ?? "",
        rating: (jsonData['rating'] ?? 0.0).toDouble(),
        ratingCount: jsonData['ratingCount'] ?? 0,
      );

      final qty = jsonData['qty'] ?? 1;
      _items[product] = qty;
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
