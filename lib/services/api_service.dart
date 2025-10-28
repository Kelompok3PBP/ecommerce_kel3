import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://fakestoreapi.com'));

  // 🔹 Ambil semua produk
  Future<List<dynamic>> getProducts() async {
    final res = await _dio.get('/products');
    return res.data; // langsung list, bukan res.data['products']
  }

  // 🔹 Ambil detail produk
  Future<Map<String, dynamic>> getProductById(int id) async {
    final res = await _dio.get('/products/$id');
    return res.data;
  }

  // 🔹 Tambah cart (dummy)
  Future<Map<String, dynamic>> addToCart(
    int userId,
    List<Map<String, dynamic>> products,
  ) async {
    final res = await _dio.post(
      '/carts',
      data: {'userId': userId, 'products': products},
    );
    return res.data;
  }
}
