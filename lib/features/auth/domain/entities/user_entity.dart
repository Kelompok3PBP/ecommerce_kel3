class UserEntity {
  final String _id;
  final String _email;
  final String _name;
  final String? _phone;
  final String? _avatar;
  final DateTime _createdAt;

  UserEntity({
    required String id,
    required String email,
    required String name,
    String? phone,
    String? avatar,
    required DateTime createdAt,
  }) : _id = id,
       _email = email,
       _name = name,
       _phone = phone,
       _avatar = avatar,
       _createdAt = createdAt {
    if (!_validateUserData()) {
      throw ArgumentError('Invalid user data');
    }
  }

  String get id => _id;
  String get email => _email;
  String get name => _name;
  String? get phone => _phone;
  String? get avatar => _avatar;
  DateTime get createdAt => _createdAt;

  bool _validateUserData() {
    return _id.isNotEmpty &&
        _email.isNotEmpty &&
        _email.contains('@') &&
        _name.isNotEmpty;
  }

  bool isProfileComplete() {
    return _phone != null && _phone.isNotEmpty && _avatar != null;
  }

  String getDisplayName() {
    return _name;
  }

  String getInitials() {
    final initials = _name
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
        .join()
        .substring(0, 2);
    return initials.length < 2 ? '${initials}U' : initials;
  }

  bool isEmailValid() {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(_email);
  }

  bool isPhoneValid() {
    if (_phone == null || _phone.isEmpty) return false;
    final cleanPhone = _phone.replaceAll(RegExp(r'[^\d]'), '');
    return RegExp(r'^\d{10,}$').hasMatch(cleanPhone);
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? avatar,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? _id,
      email: email ?? _email,
      name: name ?? _name,
      phone: phone ?? _phone,
      avatar: avatar ?? _avatar,
      createdAt: createdAt ?? _createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          _id == other._id &&
          _email == other._email &&
          _name == other._name;

  @override
  int get hashCode => _id.hashCode ^ _email.hashCode ^ _name.hashCode;

  @override
  String toString() => 'UserEntity(id: $_id, email: $_email, name: $_name)';
}
