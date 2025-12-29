import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';
import '../../data/services/api_service.dart';

class DriverDashboardPage extends StatefulWidget {
  const DriverDashboardPage({super.key});

  @override
  State<DriverDashboardPage> createState() => _DriverDashboardPageState();
}

class _DriverDashboardPageState extends State<DriverDashboardPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchAssignedOrders();
  }

  Future<void> _fetchAssignedOrders() async {
    try {
      final orders = await _apiService.getDriverOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Don't show error if it's just empty or 404 for empty list, but better to catch real errors
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error fetching orders: $e")));
      }
    }
  }

  Future<void> _updateStatus(int orderId, String newStatus) async {
    try {
      setState(() => _isLoading = true);
      await _apiService.updateDriverOrderStatus(orderId, newStatus);
      await _fetchAssignedOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Status updated to $newStatus")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Dashboard"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAssignedOrders,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text("Tidak ada pesanan aktif."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return _buildOrderCard(order);
                  },
                ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Order #${order.orderNumber}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                _buildStatusChip(order.status),
              ],
            ),
            const SizedBox(height: 8),
            // Actions
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (order.status == 'confirmed')
                  ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_bag),
                    label: const Text("Ambil Pesanan"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                    onPressed: () => _updateStatus(order.id, 'processing'),
                  ),
                if (order.status == 'processing')
                  ElevatedButton.icon(
                    icon: const Icon(Icons.motorcycle),
                    label: const Text("Mulai Antar"),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: () => _updateStatus(order.id, 'on_delivery'),
                  ),
                if (order.status == 'on_delivery')
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text("Selesai"),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => _updateStatus(order.id, 'completed'),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'confirmed':
        color = Colors.orange;
        break;
      case 'processing':
        color = Colors.cyan;
        break;
      case 'on_delivery':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(status.toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }
}
