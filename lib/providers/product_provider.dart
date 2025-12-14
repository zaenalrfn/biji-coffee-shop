import 'package:flutter/material.dart';
import '../data/services/api_service.dart';
import '../data/models/product_model.dart';
import '../data/models/category_model.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Product> _products = [];
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchProductsAndCategories() async {
    _isLoading = true;
    notifyListeners(); // Notify start loading

    try {
      _categories = await _apiService.getCategories();
      _products = await _apiService.getProducts();
    } catch (e) {
      print('Error fetching products/categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Product> getProductsByCategory(String categoryName) {
    if (categoryName == 'All' || categoryName == 'Popular') {
      return _products;
    }
    return _products
        .where((p) =>
            p.categoryName == categoryName ||
            (p.categoryId.toString() == categoryName))
        .toList();
  }
}
