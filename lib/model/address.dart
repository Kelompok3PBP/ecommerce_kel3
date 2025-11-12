class Address {
  final int id;
  final String label;
  final String street;
  final String city;
  final String postalCode;
  final String phone;

  Address({
    required this.id,
    required this.label,
    required this.street,
    required this.city,
    required this.postalCode,
    required this.phone,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json['id'] as int,
    label: json['label'] as String,
    street: json['street'] as String,
    city: json['city'] as String,
    postalCode: json['postalCode'] as String,
    phone: json['phone'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'street': street,
    'city': city,
    'postalCode': postalCode,
    'phone': phone,
  };
}
