class UserModel {
  int? _id;
  String _name;
  String _email;
  String? _avatarUrl;
  DateTime? _createdAt;

  UserModel({
    int? id,
    required String name,
    required String email,
    String? avatarUrl,
    DateTime? createdAt,
  }) : _id = id,
       _name = name,
       _email = email,
       _avatarUrl = avatarUrl,
       _createdAt = createdAt;

  int? get id => _id;
  String get name => _name;
  String get email => _email;
  String? get avatarUrl => _avatarUrl;
  DateTime? get createdAt => _createdAt;

  set setId(int? v) => _id = v;
  set setName(String v) => _name = v;
  set setEmail(String v) => _email = v;
  set setAvatarUrl(String? v) => _avatarUrl = v;
  set setCreatedAt(DateTime? v) => _createdAt = v;

  factory UserModel.fromJson(Map<String, dynamic> j) {
    return UserModel(
      id: j['id'] as int?,
      name: (j['name'] ?? '') as String,
      email: (j['email'] ?? '') as String,
      avatarUrl: j['avatarUrl'] as String?,
      createdAt: j['createdAt'] != null ? DateTime.parse(j['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': _id,
    'name': _name,
    'email': _email,
    'avatarUrl': _avatarUrl,
    'createdAt': _createdAt?.toIso8601String(),
  };

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? _id,
      name: name ?? _name,
      email: email ?? _email,
      avatarUrl: avatarUrl ?? _avatarUrl,
      createdAt: createdAt ?? _createdAt,
    );
  }

  String describe() => 'User: $_name (${_email})';
}
