import '../../../profile/domain/entities/user.dart';

class Address extends UserModel {
  String _label;
  String _street;
  String _city;
  String _postalCode;
  String _phone;

  double? _latitude;
  double? _longitude;

  Address({
    required int id,
    required String label,
    required String street,
    required String city,
    required String postalCode,
    required String phone,
    double? latitude,
    double? longitude,
  }) : _label = label,
       _street = street,
       _city = city,
       _postalCode = postalCode,
       _phone = phone,
       _latitude = latitude,
       _longitude = longitude,
       super(id: id, name: label, email: '');

  @override
  int get id => super.id ?? 0;

  @override
  String get name => _label;

  String get label => _label;
  String get street => _street;
  String get city => _city;
  String get postalCode => _postalCode;
  String get phone => _phone;

  double? get latitude => _latitude;
  double? get longitude => _longitude;

  @override
  set setId(int? v) => super.setId = v;

  set label(String value) {
    _label = value;
    super.setName = value;
  }

  set street(String value) => _street = value;
  set city(String value) => _city = value;
  set postalCode(String value) => _postalCode = value;
  set phone(String value) => _phone = value;

  set latitude(double? value) => _latitude = value;
  set longitude(double? value) => _longitude = value;

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: (json['id'] as num?)?.toInt() ?? 0,
    label: json['label'] ?? json['name'] ?? '',
    street: json['street'] ?? '',
    city: json['city'] ?? '',
    postalCode: json['postalCode'] ?? '',
    phone: json['phone'] ?? '',
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
  );

  @override
  Map<String, dynamic> toJson() {
    final parent = super.toJson();
    parent.addAll({
      'label': _label,
      'street': _street,
      'city': _city,
      'postalCode': _postalCode,
      'phone': _phone,
      'latitude': _latitude,
      'longitude': _longitude,
    });
    return parent;
  }

  @override
  Address copyWith({
    int? id,
    String? name,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
    String? label,
    String? street,
    String? city,
    String? postalCode,
    String? phone,
    double? latitude,
    double? longitude,
  }) {
    return Address(
      id: id ?? (super.id ?? 0),
      label: label ?? name ?? _label,
      street: street ?? _street,
      city: city ?? _city,
      postalCode: postalCode ?? _postalCode,
      phone: phone ?? _phone,
      latitude: latitude ?? _latitude,
      longitude: longitude ?? _longitude,
    );
  }

  @override
  String describe() => 'Address: $_label, $_street, $_city';
}
