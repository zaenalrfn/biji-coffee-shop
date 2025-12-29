import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/coupon_provider.dart';
import '../../core/routes/app_routes.dart';

class ManageCouponsPage extends StatefulWidget {
  const ManageCouponsPage({super.key});

  @override
  State<ManageCouponsPage> createState() => _ManageCouponsPageState();
}

class _ManageCouponsPageState extends State<ManageCouponsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<CouponProvider>(context, listen: false).fetchCoupons());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Kelola Kupon'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Consumer<CouponProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.coupons.isEmpty) {
            return const Center(child: Text('Belum ada kupon.'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchCoupons(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.coupons.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final coupon = provider.coupons[index];
                return Card(
                  elevation: 2,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      coupon.code,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Diskon: ${coupon.type == 'percent' ? '${coupon.value}%' : 'Rp ${coupon.value}'}',
                          style: const TextStyle(color: Colors.green),
                        ),
                        Text(
                            'Min. Belanja: Rp ${coupon.minPurchase.toStringAsFixed(0)}'),
                        if (coupon.expiresAt != null)
                          Text('Expired: ${coupon.expiresAt}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, coupon.id!),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF523946),
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addEditCoupon);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kupon'),
        content: const Text('Yakin ingin menghapus kupon ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Provider.of<CouponProvider>(context, listen: false)
                    .deleteCoupon(id);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kupon dihapus')));
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Gagal: $e')));
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }
}
