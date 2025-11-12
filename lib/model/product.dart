class Product {
  int _id;
  String _title;
  double _price;
  String _description;
  String _category;
  String _image;
  double _rating;
  int _ratingCount;

  // 🔹 Constructor
  Product({
    required int id,
    required String title,
    required double price,
    required String description,
    required String category,
    required String image,
    required double rating,
    required int ratingCount,
  }) : _id = id,
       _title = title,
       _price = price,
       _description = description,
       _category = category,
       _image = image,
       _rating = rating,
       _ratingCount = ratingCount;

  int get id => _id;
  String get title => _title;
  double get price => _price;
  String get description => _description;
  String get category => _category;
  String get image => _image;
  double get rating => _rating;
  int get ratingCount => _ratingCount;

  set id(int value) => _id = value;
  set title(String value) => _title = value;
  set price(double value) => _price = value;
  set description(String value) => _description = value;
  set category(String value) => _category = value;
  set image(String value) => _image = value;
  set rating(double value) => _rating = value;
  set ratingCount(int value) => _ratingCount = value;

  factory Product.fromJson(Map<String, dynamic> json) {
    final ratingData = json['rating'] ?? {};
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Produk Tanpa Nama',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] ?? 0.0),
      description: json['description'] ?? '',
      category: json['category'] ?? 'Uncategorized',
      image:
          json['image'] ??
          "https://cdn-icons-png.flaticon.com/512/869/869636.png",
      rating: (ratingData['rate'] ?? 0).toDouble(),
      ratingCount: ratingData['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'title': _title,
      'price': _price,
      'description': _description,
      'category': _category,
      'image': _image,
      'rating': {'rate': _rating, 'count': _ratingCount},
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other._id == _id;
  }

  @override
  int get hashCode => _id.hashCode;
}
