import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/product.dart';

class CartState {
  final Map<Product, int> items;

  CartState({required this.items});

  factory CartState.initial() => CartState(items: {});

  double get total {
    double t = 0;
    items.forEach((product, qty) {
      t += product.price * qty;
    });
    return t;
  }

  CartState copyWith({Map<Product, int>? items}) {
    return CartState(items: items ?? Map<Product, int>.from(this.items));
  }
}

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState.initial()) {
    _loadCart();
  }

  void add(Product product) {
    final newItems = Map<Product, int>.from(state.items);
    newItems[product] = (newItems[product] ?? 0) + 1;
    emit(state.copyWith(items: newItems));
    _saveCart(newItems);
  }

  void decrease(Product product) {
    final newItems = Map<Product, int>.from(state.items);
    if (!newItems.containsKey(product)) return;
    if (newItems[product]! > 1) {
      newItems[product] = newItems[product]! - 1;
    } else {
      newItems.remove(product);
    }
    emit(state.copyWith(items: newItems));
    _saveCart(newItems);
  }

  void remove(Product product) {
    final newItems = Map<Product, int>.from(state.items);
    newItems.remove(product);
    emit(state.copyWith(items: newItems));
    _saveCart(newItems);
  }

  void clear() {
    emit(CartState.initial());
    _saveCart({});
  }

  Future<void> _saveCart(Map<Product, int> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = items.entries.map((e) {
      final p = e.key;
      return jsonEncode({
        'id': p.id,
        'title': p.title,
        'price': p.price,
        'description': p.description,
        'category': p.category,
        'image': p.image,
        'rating': p.rating,
        'ratingCount': p.ratingCount,
        'qty': e.value,
      });
    }).toList();
    await prefs.setStringList('cart_items', encoded);
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> data = prefs.getStringList('cart_items') ?? [];
    final Map<Product, int> items = {};
    for (var s in data) {
      try {
        final j = jsonDecode(s);
        final p = Product(
          id: j['id'] ?? 0,
          title: j['title'] ?? 'Produk Tanpa Nama',
          price: (j['price'] as num).toDouble(),
          description: j['description'] ?? '',
          category: j['category'] ?? '',
          image: j['image'] ?? '',
          rating: (j['rating'] ?? 0.0).toDouble(),
          ratingCount: j['ratingCount'] ?? 0,
        );
        final qty = j['qty'] ?? 1;
        items[p] = qty;
      } catch (_) {}
    }
    emit(state.copyWith(items: items));
  }
}
