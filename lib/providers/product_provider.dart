import 'package:flutter/material.dart';
import '../data/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
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

  Future<void> addProduct(Map<String, String> fields,
      [XFile? imageFile]) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newProduct = await _apiService.createProduct(fields, imageFile);
      _products.add(newProduct);
      notifyListeners();
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editProduct(int id, Map<String, String> fields,
      [XFile? imageFile]) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedProduct =
          await _apiService.updateProduct(id, fields, imageFile);
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================= CATEGORY CRUD =================

  Future<void> addCategory(String name, {String? iconName}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newCategory =
          await _apiService.createCategory(name, iconName: iconName);
      _categories.add(newCategory);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> editCategory(int id, String name, {String? iconName}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updatedCategory =
          await _apiService.updateCategory(id, name, iconName: iconName);
      final index = _categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        _categories[index] = updatedCategory;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
