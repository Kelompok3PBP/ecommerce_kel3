class Address {
  int _id;
  String _label;
  String _street;
  String _city;
  String _postalCode;
  String _phone;

  Address({
    required int id,
    required String label,
    required String street,
    required String city,
    required String postalCode,
    required String phone,
  }) : _id = id,
       _label = label,
       _street = street,
       _city = city,
       _postalCode = postalCode,
       _phone = phone;

  // Getters
  int get id => _id;
  String get label => _label;
  String get street => _street;
  String get city => _city;
  String get postalCode => _postalCode;
  String get phone => _phone;

  // Setters (allow controlled mutation)
  set id(int value) => _id = value;
  set label(String value) => _label = value;
  set street(String value) => _street = value;
  set city(String value) => _city = value;
  set postalCode(String value) => _postalCode = value;
  set phone(String value) => _phone = value;

  // JSON
  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: (json['id'] as num?)?.toInt() ?? 0,
    label: json['label'] ?? '',
    street: json['street'] ?? '',
    city: json['city'] ?? '',
    postalCode: json['postalCode'] ?? '',
    phone: json['phone'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': _id,
    'label': _label,
    'street': _street,
    'city': _city,
    'postalCode': _postalCode,
    'phone': _phone,
  };

  Address copyWith({
    int? id,
    String? label,
    String? street,
    String? city,
    String? postalCode,
    String? phone,
  }) {
    return Address(
      id: id ?? _id,
      label: label ?? _label,
      street: street ?? _street,
      city: city ?? _city,
      postalCode: postalCode ?? _postalCode,
      phone: phone ?? _phone,
    );
  }

  @override
  String toString() =>
      'Address(id: $_id, label: $_label, street: $_street, city: $_city, postalCode: $_postalCode, phone: $_phone)';
}
