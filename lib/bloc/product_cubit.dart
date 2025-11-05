import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/product.dart';
import '../services/api_service.dart';

class ProductState {
  final bool loading;
  final List<Product> products;
  final String? error;

  ProductState({required this.loading, required this.products, this.error});

  factory ProductState.initial() => ProductState(loading: true, products: []);

  ProductState copyWith({
    bool? loading,
    List<Product>? products,
    String? error,
  }) {
    return ProductState(
      loading: loading ?? this.loading,
      products: products ?? this.products,
      error: error,
    );
  }
}

class ProductCubit extends Cubit<ProductState> {
  final ApiService _apiService;

  ProductCubit(this._apiService) : super(ProductState.initial()) {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final raw = await _apiService.getProducts();
      final products = raw.map((j) => Product.fromJson(j)).toList();
      emit(state.copyWith(loading: false, products: products, error: null));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
