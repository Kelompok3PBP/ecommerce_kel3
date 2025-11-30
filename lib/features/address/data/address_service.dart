import 'package:ecommerce/features/address/domain/entities/address.dart';

class AddressService {
  final List<Address> _store = [];
  int _nextId = 1;

  AddressService() {
    _store.add(
      Address(
        id: _nextId++,
        label: 'Rumah',
        street: 'Jl. Contoh No.1',
        city: 'Jakarta',
        postalCode: '12345',
        phone: '08123456789',
      ),
    );
  }

  Future<List<Address>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_store);
  }

  Future<Address> fetchById(int id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final a = _store.firstWhere(
      (e) => e.id == id,
      orElse: () => throw Exception('Address not found'),
    );
    return a;
  }

  Future<Address> create(Address address) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newAddress = Address(
      id: _nextId++,
      label: address.label,
      street: address.street,
      city: address.city,
      postalCode: address.postalCode,
      phone: address.phone,
    );
    _store.add(newAddress);
    return newAddress;
  }

  Future<Address> update(Address address) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _store.indexWhere((e) => e.id == address.id);
    if (idx == -1) throw Exception('Address not found');
    _store[idx] = address;
    return address;
  }

  Future<void> delete(int id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _store.removeWhere((e) => e.id == id);
  }
}
