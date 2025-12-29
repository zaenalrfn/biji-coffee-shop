import 'package:flutter/material.dart';
import '../data/models/order_model.dart';
import '../data/services/api_service.dart';

class AdminTransactionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Filtered Getters
  List<Order> get pendingOrders =>
      _orders.where((o) => o.status == 'pending').toList();
  List<Order> get paidOrders => _orders
      .where((o) => o.status == 'paid' || o.status == 'processing')
      .toList();
  List<Order> get shippedOrders =>
      _orders.where((o) => o.status == 'shipped').toList();
  List<Order> get completedOrders =>
      _orders.where((o) => o.status == 'completed').toList();
  List<Order> get cancelledOrders =>
      _orders.where((o) => o.status == 'cancelled').toList();

  Future<void> fetchAllOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Assuming getOrders returns all orders for Admin
      _orders = await _apiService.getAdminOrders();
      // Sort by latest first
      _orders.sort((a, b) => b.id.compareTo(a.id));
    } catch (e) {
      _errorMessage = e.toString();
      print('Error fetching admin orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(int orderId, String newStatus) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedOrder =
          await _apiService.updateOrderStatus(orderId, newStatus);

      // Update local list
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        // Merge missing data (User, Items) from old order to new order
        final oldOrder = _orders[index];
        final mergedOrder = updatedOrder.copyWith(
          user: updatedOrder.user ?? oldOrder.user,
          items: (updatedOrder.items == null || updatedOrder.items!.isEmpty)
              ? oldOrder.items
              : updatedOrder.items,
          shippingAddress:
              updatedOrder.shippingAddress ?? oldOrder.shippingAddress,
        );
        _orders[index] = mergedOrder;
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('Error updating status: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteOrder(int orderId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.deleteOrder(orderId);
      _orders.removeWhere((o) => o.id == orderId);
    } catch (e) {
      _errorMessage = e.toString();
      print('Error deleting order: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
