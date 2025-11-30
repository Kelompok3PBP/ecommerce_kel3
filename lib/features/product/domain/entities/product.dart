/// Abstract base class for products with encapsulation and polymorphism support
abstract class BaseProduct {
  /// Get product identifier
  int getId();

  /// Get product price
  double getPrice();

  /// Validate product data
  bool validateData();

  /// Get serializable map representation
  Map<String, dynamic> toJson();
}

/// Product entity with encapsulation (private fields, getters/setters)
/// Demonstrates OOP principles: encapsulation and extensibility for polymorphism
class Product implements BaseProduct {
  // Private fields - ENCAPSULATION
  int _id;
  String _title;
  double _price;
  String _description;
  String _category;
  String _image;
  double _rating;
  int _ratingCount;

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
       _ratingCount = ratingCount {
    // Validate data on initialization
    if (!validateData()) {
      throw ArgumentError('Invalid product data');
    }
  }

  // Getters - controlled access to private fields (ENCAPSULATION)
  @override
  int getId() => _id;
  int get id => _id;

  String get title => _title;

  @override
  double getPrice() => _price;
  double get price => _price;

  String get description => _description;

  String get category => _category;

  String get image => _image;

  double get rating => _rating;

  int get ratingCount => _ratingCount;

  // Setters - controlled modification of private fields (ENCAPSULATION)
  set id(int value) {
    if (value > 0) {
      _id = value;
    }
  }

  set title(String value) {
    if (value.isNotEmpty) {
      _title = value;
    }
  }

  set price(double value) {
    if (value >= 0) {
      _price = value;
    }
  }

  set description(String value) {
    _description = value;
  }

  set category(String value) {
    if (value.isNotEmpty) {
      _category = value;
    }
  }

  set image(String value) {
    _image = value;
  }

  set rating(double value) {
    if (value >= 0 && value <= 5) {
      _rating = value;
    }
  }

  set ratingCount(int value) {
    if (value >= 0) {
      _ratingCount = value;
    }
  }

  /// Validate product data - ENCAPSULATION OF VALIDATION LOGIC
  @override
  bool validateData() {
    return _id > 0 &&
        _title.isNotEmpty &&
        _price >= 0 &&
        _category.isNotEmpty &&
        _rating >= 0 &&
        _rating <= 5 &&
        _ratingCount >= 0;
  }

  /// Calculate discounted price
  double getDiscountedPrice(double discountPercent) {
    if (discountPercent < 0 || discountPercent > 100) {
      throw ArgumentError('Discount must be between 0 and 100');
    }
    return _price * (1 - discountPercent / 100);
  }

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

  @override
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
