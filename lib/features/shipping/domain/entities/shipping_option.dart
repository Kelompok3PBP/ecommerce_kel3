// lib/features/shipping/domain/entities/shipping_option.dart

import 'package:equatable/equatable.dart';

class ShippingOption extends Equatable {
  final String id;
  final String name; // Contoh: "Reguler", "Next Day"
  final String serviceType; // Contoh: "JNE Reg", "SiCepat BEST"
  final double cost;
  final String? estimate; // Contoh: "2-3 hari"
  final String courierName; // Contoh: "JNE", "Sicepat", "GoSend"

  const ShippingOption({
    required this.id,
    required this.name,
    required this.serviceType,
    required this.cost,
    required this.courierName,
    this.estimate,
  });

  // Metode untuk konversi dari Map (misalnya dari API)
  factory ShippingOption.fromJson(Map<String, dynamic> json) {
    // Helper function untuk parsing string
    String _s(String key) => (json[key] ?? '').toString();
    // Helper function untuk parsing double dengan aman
    double _d(String key) => (json[key] as num?)?.toDouble() ?? 0.0;

    return ShippingOption(
      id: _s('id'),
      name: _s('name'),
      serviceType: _s('serviceType'),
      cost: _d('cost'),
      courierName: _s('courierName'),
      estimate: json['estimate'] as String?,
    );
  }

  // Metode untuk konversi ke Map (misalnya untuk dikirim saat checkout atau disimpan di PurchaseReceipt)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'serviceType': serviceType,
      'cost': cost,
      'courierName': courierName,
      'estimate': estimate,
    };
  }

  // Implementasi Equatable untuk perbandingan objek
  @override
  List<Object?> get props => [
    id,
    name,
    serviceType,
    cost,
    courierName,
    estimate,
  ];
}
