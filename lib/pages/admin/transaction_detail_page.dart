import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/order_model.dart';
import '../../providers/admin_transaction_provider.dart';

class TransactionDetailPage extends StatefulWidget {
  final Order order;

  const TransactionDetailPage({super.key, required this.order});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
  }

  void _updateStatus(String newStatus) async {
    final provider =
        Provider.of<AdminTransactionProvider>(context, listen: false);
    try {
      await provider.updateStatus(widget.order.id, newStatus);
      setState(() {
        _currentStatus = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if status updated in provider match this page,
    // but local state _currentStatus is fine for immediate feedback.

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Status & Actions
            _buildStatusSection(),
            const Divider(height: 30),

            // 2. User Info
            _buildSectionTitle('Customer Info'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundImage: (widget.order.user?.profilePhotoUrl != null)
                    ? NetworkImage(widget.order.user!.profilePhotoUrl!)
                    : const AssetImage('assets/images/profile1.jpg')
                        as ImageProvider,
              ),
              title: Text(widget.order.user?.name ?? 'Unknown'),
              subtitle: Text(widget.order.user?.email ?? '-'),
            ),
            const Divider(height: 30),

            // 3. Shipping Address
            _buildSectionTitle('Shipping Address'),
            if (widget.order.shippingAddress != null)
              _buildAddressInfo(widget.order.shippingAddress!)
            else
              const Text("No shipping address provided."),
            const Divider(height: 30),

            // 4. Items
            _buildSectionTitle('Ordered Items'),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.order.items?.length ?? 0,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = widget.order.items![index];
                return ListTile(
                  leading: (item.product?.imageUrl != null)
                      ? Image.network(item.product!.imageUrl!,
                          width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.coffee),
                  title: Text(item.product?.name ?? 'Unknown Product'),
                  subtitle: Text('Qty: ${item.quantity}'),
                  trailing: Text(
                      'Rp ${(item.price * item.quantity).toStringAsFixed(0)}'),
                );
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Price',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Rp ${widget.order.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Current Status:', style: TextStyle(color: Colors.grey)),
            Row(
              children: [
                Text(_currentStatus.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                PopupMenuButton<String>(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.brown,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text('Update Status',
                        style: TextStyle(color: Colors.white)),
                  ),
                  onSelected: _updateStatus,
                  itemBuilder: (context) => [
                    'pending',
                    'paid',
                    'processing',
                    'shipped',
                    'completed',
                    'cancelled'
                  ]
                      .map((s) =>
                          PopupMenuItem(value: s, child: Text(s.toUpperCase())))
                      .toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildAddressInfo(Map<String, dynamic> address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(address['recipient_name'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(address['address_line'] ?? ''),
        Text('${address['city']}, ${address['state']} ${address['zip_code']}'),
        Text(address['country'] ?? ''),
      ],
    );
  }
}
