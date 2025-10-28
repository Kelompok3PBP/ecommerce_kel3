import 'package:flutter/material.dart';

class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double rating;
  final int ratingCount;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
    required this.ratingCount,
  });

  /// Convert JSON → Model
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

  /// Convert Model → JSON (buat post/put)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
      'rating': {'rate': rating, 'count': ratingCount},
    };
  }
}
