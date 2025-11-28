import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://fakestoreapi.com'));

  Future<List<dynamic>> getProducts() async {
    final res = await _dio.get('/products');
    return res.data;
  }

  Future<dynamic> get(String path) async {
    final response = await _dio.get(path);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('GET failed: ${response.statusCode}');
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await _dio.post(path, data: body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    } else {
      throw Exception('POST failed: ${response.statusCode}');
    }
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final response = await _dio.put(path, data: body);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('PUT failed: ${response.statusCode}');
    }
  }

  Future<void> delete(String path) async {
    final response = await _dio.delete(path);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('DELETE failed: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getProductById(int id) async {
    final res = await _dio.get('/products/$id');
    return res.data;
  }

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
