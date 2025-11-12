class OrderModel {
  int? _id;
  List<Map<String, dynamic>> _items;
  double _total;
  DateTime _createdAt;

  OrderModel({
    int? id,
    required List<Map<String, dynamic>> items,
    required double total,
    DateTime? createdAt,
  }) : _id = id,
       _items = items,
       _total = total,
       _createdAt = createdAt ?? DateTime.now();

  int? get id => _id;
  List<Map<String, dynamic>> get items => List.unmodifiable(_items);
  double get total => _total;
  DateTime get createdAt => _createdAt;

  set setId(int? v) => _id = v;
  set setItems(List<Map<String, dynamic>> v) => _items = v;
  set setTotal(double v) => _total = v;
  set setCreatedAt(DateTime v) => _createdAt = v;

  factory OrderModel.fromJson(Map<String, dynamic> j) {
    return OrderModel(
      id: j['id'] as int?,
      items:
          (j['items'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      total: (j['total'] as num?)?.toDouble() ?? 0.0,
      createdAt: j['createdAt'] != null ? DateTime.parse(j['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': _id,
    'items': _items,
    'total': _total,
    'createdAt': _createdAt.toIso8601String(),
  };

  OrderModel copyWith({
    int? id,
    List<Map<String, dynamic>>? items,
    double? total,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? _id,
      items: items ?? List<Map<String, dynamic>>.from(_items),
      total: total ?? _total,
      createdAt: createdAt ?? _createdAt,
    );
  }
}
