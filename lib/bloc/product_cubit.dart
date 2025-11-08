import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/product.dart';
import '../services/api_service.dart';

class ProductState {
  final bool loading;
  final List<Product> products;
  final String? error;
  final Product? selectedProduct;
  final bool loadingSelected;

  ProductState({
    required this.loading,
    required this.products,
    this.error,
    this.selectedProduct,
    this.loadingSelected = false,
  });

  factory ProductState.initial() => ProductState(loading: true, products: []);

  ProductState copyWith({
    bool? loading,
    List<Product>? products,
    ValueGetter<String?>? error,
    ValueGetter<Product?>? selectedProduct,
    bool? loadingSelected,
  }) {
    return ProductState(
      loading: loading ?? this.loading,
      products: products ?? this.products,
      error: error != null ? error() : this.error,
      selectedProduct: selectedProduct != null
          ? selectedProduct()
          : this.selectedProduct,
      loadingSelected: loadingSelected ?? this.loadingSelected,
    );
  }
}

class ProductCubit extends Cubit<ProductState> {
  final ApiService _apiService;

  ProductCubit(this._apiService) : super(ProductState.initial()) {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    emit(state.copyWith(loading: true, error: () => null));
    try {
      final raw = await _apiService.getProducts();
      final products = raw.map((j) => Product.fromJson(j)).toList();
      emit(
        state.copyWith(loading: false, products: products, error: () => null),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: () => e.toString()));
    }
  }

  Future<void> fetchProductById(int id) async {
    emit(
      state.copyWith(
        loadingSelected: true,
        error: () => null,
        selectedProduct: () => null,
      ),
    );

    try {
      Product? foundProduct;
      try {
        foundProduct = state.products.firstWhere((p) => p.id == id);
      } catch (_) {
        foundProduct = null;
      }

      Product? productToEmit;
      if (foundProduct != null) {
        productToEmit = foundProduct;
      } else {
        final raw = await _apiService.getProductById(id);
        productToEmit = Product.fromJson(raw);
      }

      emit(
        state.copyWith(
          loadingSelected: false,
          selectedProduct: () => productToEmit,
          error: () => null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loadingSelected: false,
          error: () => e.toString(),
          selectedProduct: () => null,
        ),
      );
    }
  }
}
