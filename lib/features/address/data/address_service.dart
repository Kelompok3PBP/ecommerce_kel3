import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce/features/address/domain/entities/address.dart';

class AddressService {
  final List<Address> _store = [];
  int _nextId = 1;

  AddressService() {
    _ensureInitialized();
  }

  Future<void> _ensureInitialized() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('addresses');
    if (raw == null) {
      final seed = Address(
        id: _nextId++,
        label: 'Rumah',
        street: 'Jl. Contoh No.1',
        city: 'Jakarta',
        postalCode: '12345',
        phone: '08123456789',
      );
      _store.add(seed);
      await _saveToPrefs();
      return;
    }

    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      _store.clear();
      for (var item in list) {
        if (item is Map<String, dynamic>) {
          _store.add(Address.fromJson(item));
        } else if (item is String) {
          final m = jsonDecode(item) as Map<String, dynamic>;
          _store.add(Address.fromJson(m));
        }
      }
      if (_store.isNotEmpty) {
        final maxId = _store.map((e) => e.id).reduce((a, b) => a > b ? a : b);
        _nextId = maxId + 1;
      }
    } catch (_) {}
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _store.map((e) => e.toJson()).toList();
    await prefs.setString('addresses', jsonEncode(list));
  }

  Future<List<Address>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 150));
    await _ensureInitialized();
    return List.unmodifiable(_store);
  }

  Future<Address> fetchById(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    await _ensureInitialized();
    final a = _store.firstWhere(
      (e) => e.id == id,
      orElse: () => throw Exception('Address not found'),
    );
    return a;
  }

  Future<Address> create(Address address) async {
    await Future.delayed(const Duration(milliseconds: 150));
    await _ensureInitialized();
    final newAddress = Address(
      id: _nextId++,
      label: address.label,
      street: address.street,
      city: address.city,
      postalCode: address.postalCode,
      phone: address.phone,
      latitude: address.latitude,
      longitude: address.longitude,
    );
    _store.add(newAddress);
    await _saveToPrefs();
    return newAddress;
  }

  Future<Address> update(Address address) async {
    await Future.delayed(const Duration(milliseconds: 150));
    await _ensureInitialized();
    final idx = _store.indexWhere((e) => e.id == address.id);
    if (idx == -1) throw Exception('Address not found');
    _store[idx] = address;
    await _saveToPrefs();
    return address;
  }

  Future<void> delete(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    await _ensureInitialized();
    _store.removeWhere((e) => e.id == id);
    await _saveToPrefs();
  }
}
