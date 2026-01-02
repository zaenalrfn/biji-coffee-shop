import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';
// Import Driver
import '../../data/services/api_service.dart';

class ManageOrdersPage extends StatefulWidget {
  const ManageOrdersPage({super.key});

  @override
  State<ManageOrdersPage> createState() => _ManageOrdersPageState();
}

class _ManageOrdersPageState extends State<ManageOrdersPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final orders = await _apiService.getAdminOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _assignDriver(int orderId) async {
    try {
      final drivers = await _apiService.getDrivers();

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Pilih Driver",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: drivers.isEmpty
                  ? const Center(child: Text("Tidak ada driver tersedia"))
                  : ListView.builder(
                      itemCount: drivers.length,
                      itemBuilder: (context, index) {
                        final driver = drivers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: driver.photoUrl != null
                                ? NetworkImage(driver.photoUrl!)
                                : null,
                            child: driver.photoUrl == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(driver.name),
                          subtitle: Text(driver.isActive
                              ? "Tersedia" // Or 'Pending'/'Active'
                              : "Tidak Aktif"), // Or logic based on backend meaning
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _performAssign(orderId, driver.id);
                            },
                            child: const Text("Pilih"),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error fetching drivers: $e")));
      }
    }
  }

  Future<void> _performAssign(int orderId, int driverId) async {
    try {
      setState(() => _isLoading = true);
      await _apiService.assignDriver(orderId, driverId);
      await _fetchOrders(); // Refresh list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Driver assigned successfully!")));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Pesanan")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
    final bool isPaid = order.paymentStatus == 'paid' ||
        order.paymentStatus == 'settlement' ||
        order.paymentStatus == 'capture';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Order #${order.orderNumber}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(order.status.toUpperCase(),
                        style: TextStyle(
                            color: order.status == 'cancelled'
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold)),
                    Text(
                      isPaid ? "PAID" : "UNPAID",
                      style: TextStyle(
                        fontSize: 12,
                        color: isPaid ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person),
              title: Text(order.user?.name ?? 'Unknown User'),
              subtitle: Text("Total: Rp ${order.totalPrice}"),
            ),
            if (order.driver != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.motorcycle, color: Colors.blue),
                title: Text("Driver: ${order.driver!.name}"),
              ),

            const Divider(),

            // Only show Assign Button if Order is PAID and NOT Cancelled/Completed
            if (isPaid &&
                order.status != 'cancelled' &&
                order.status != 'completed' &&
                order.status != 'on_delivery') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: Text(
                      order.driver == null ? "Assign Driver" : "Ganti Driver"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white),
                  onPressed: () => _assignDriver(order.id),
                ),
              )
            ] else if (!isPaid && order.status != 'cancelled') ...[
              const Text("Menunggu Pembayaran...",
                  style: TextStyle(color: Colors.orange)),
            ]
          ],
        ),
      ),
    );
  }
}
