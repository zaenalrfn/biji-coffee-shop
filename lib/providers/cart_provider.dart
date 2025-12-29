import 'package:flutter/material.dart';
import '../data/services/api_service.dart';
import '../data/models/cart_item_model.dart';

class CartProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<CartItem> _cartItems = [];
  bool _isLoading = false;

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;

  double _discountAmount = 0;
  String? _appliedCouponCode;

  double get discountAmount => _discountAmount;
  String? get appliedCouponCode => _appliedCouponCode;

  double get totalPrice {
    double total = 0;
    for (var item in _cartItems) {
      if (item.product != null) {
        total += item.product!.price * item.quantity;
      }
    }
    return total - _discountAmount; // Subtract discount
  }

  double get subtotal {
    double total = 0;
    for (var item in _cartItems) {
      if (item.product != null) {
        total += item.product!.price * item.quantity;
      }
    }
    return total;
  }

  Future<void> applyCoupon(String code) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Assuming checkCoupon returns { "discount_amount": 5000 ... }
      final result = await _apiService.checkCoupon(code, subtotal);

      _discountAmount =
          double.tryParse(result['discount_amount'].toString()) ?? 0.0;
      _appliedCouponCode = code;
    } catch (e) {
      _discountAmount = 0;
      _appliedCouponCode = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void removeCoupon() {
    _discountAmount = 0;
    _appliedCouponCode = null;
    notifyListeners();
  }

  void clearCartLocal() {
    _cartItems = [];
    _discountAmount = 0;
    _appliedCouponCode = null;
    notifyListeners();
  }

  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cartItems = await _apiService.getCart();
    } catch (e) {
      print('Error fetching cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(int productId, int quantity) async {
    try {
      await _apiService.addToCart(productId, quantity);
      await fetchCart(); // Refresh cart
    } catch (e) {
      print('Error adding to cart: $e');
      rethrow;
    }
  }

  Future<void> removeFromCart(int cartId) async {
    try {
      await _apiService.removeFromCart(cartId);
      _cartItems.removeWhere((item) => item.id == cartId);
      notifyListeners();
    } catch (e) {
      print('Error removing from cart: $e');
      rethrow;
    }
  }

  Future<void> updateCartItem(int cartId, int quantity) async {
    try {
      await _apiService.updateCartItem(cartId, quantity);
      final index = _cartItems.indexWhere((item) => item.id == cartId);
      if (index != -1) {
        _cartItems[index] = CartItem(
          id: _cartItems[index].id,
          productId: _cartItems[index].productId,
          quantity: quantity,
          product: _cartItems[index].product,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error updating cart item: $e');
      rethrow;
    }
  }
}
