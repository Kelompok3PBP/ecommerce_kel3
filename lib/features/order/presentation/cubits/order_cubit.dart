import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce/features/product/domain/product.dart';

class Order {
  final int id;
  final List<Map<String, dynamic>> items;
  final double total;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'items': items,
    'total': total,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Order.fromJson(Map<String, dynamic> j) => Order(
    id: j['id'] ?? 0,
    items: List<Map<String, dynamic>>.from(j['items'] ?? []),
    total: (j['total'] as num).toDouble(),
    createdAt: DateTime.parse(j['createdAt']),
  );
}

class OrderState {
  final bool loading;
  final List<Order> orders;

  OrderState({required this.loading, required this.orders});

  factory OrderState.initial() => OrderState(loading: false, orders: []);

  OrderState copyWith({bool? loading, List<Order>? orders}) => OrderState(
    loading: loading ?? this.loading,
    orders: orders ?? List<Order>.from(this.orders),
  );
}

class OrderCubit extends Cubit<OrderState> {
  OrderCubit() : super(OrderState.initial()) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    emit(state.copyWith(loading: true));
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('orders') ?? [];
    final orders = data
        .map((s) => Order.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
    emit(state.copyWith(loading: false, orders: orders));
  }

  Future<void> placeOrder(Map<Product, int> cartItems) async {
    emit(state.copyWith(loading: true));
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList('orders') ?? [];
    final id = DateTime.now().millisecondsSinceEpoch;
    final items = cartItems.entries.map((e) {
      final p = e.key;
      return {
        'id': p.id,
        'title': p.title,
        'price': p.price,
        'qty': e.value,
        'image': p.image,
      };
    }).toList();
    final total = cartItems.entries.fold<double>(
      0,
      (acc, e) => acc + e.key.price * e.value,
    );
    final order = Order(
      id: id,
      items: items,
      total: total,
      createdAt: DateTime.now(),
    );
    final newList = List<String>.from(existing)
      ..insert(0, jsonEncode(order.toJson()));
    await prefs.setStringList('orders', newList);
    await loadOrders();
  }

  Future<void> clearOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('orders');
    emit(state.copyWith(orders: []));
  }
}
