import 'package:flutter/material.dart';
import '../data/services/api_service.dart';
import '../data/models/order_model.dart';

class OrderProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await _apiService.getOrders();
    } catch (e) {
      print('Error fetching orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Checkout State
  Map<String, dynamic>? _shippingAddress;
  String? _paymentMethod;

  void setShippingAddress(Map<String, dynamic> address) {
    _shippingAddress = address;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  Future<void> createOrder() async {
    _isLoading = true;
    notifyListeners();
    if (_shippingAddress == null) {
      throw Exception(
          'Shipping Address is missing. Please fill in your address.');
    }
    if (_paymentMethod == null) {
      throw Exception(
          'Payment Method is missing. Please select a payment method.');
    }

    try {
      await _apiService.createOrder(
        shippingAddress: _shippingAddress,
        paymentMethod: _paymentMethod,
      );
      await fetchOrders(); // Refresh orders
      // Reset state
      _shippingAddress = null;
      _paymentMethod = null;
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
