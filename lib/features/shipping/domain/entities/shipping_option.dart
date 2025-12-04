import 'package:equatable/equatable.dart';

class ShippingOption extends Equatable {
  final String id;
  final String name;
  final String serviceType;
  final double cost;
  final String? estimate;
  final String courierName;

  const ShippingOption({
    required this.id,
    required this.name,
    required this.serviceType,
    required this.cost,
    required this.courierName,
    this.estimate,
  });

  factory ShippingOption.fromJson(Map<String, dynamic> json) {
    String _s(String key) => (json[key] ?? '').toString();
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
