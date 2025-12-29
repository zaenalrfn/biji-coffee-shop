import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/routes/app_routes.dart';

class CustomSideNav extends StatelessWidget {
  const CustomSideNav({super.key});

  // Fungsi navigasi
  void _navigateTo(BuildContext context, String routeName) {
    Navigator.pop(context); // tutup drawer dulu
    Navigator.pushNamed(context, routeName); // lalu pindah halaman
  }

  @override
  Widget build(BuildContext context) {
    // Access user data
    final user = Provider.of<AuthProvider>(context).user;
    final bool isAdmin = user?.roles.contains('admin') ?? false;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ====== HEADER ======
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Main Menu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(thickness: 1, height: 1),

            // ====== LIST MENU ======
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.home_outlined,
                    title: 'Home',
                    route: AppRoutes.home,
                  ),
                  if (isAdmin)
                    ExpansionTile(
                      leading: const Icon(Icons.store_mall_directory,
                          color: Colors.black54),
                      title: const Text(
                        'Kelola Toko',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: _buildMenuItem(
                            context,
                            icon: Icons.inventory_2_outlined,
                            title: 'Kelola Produk',
                            route: AppRoutes.manageProducts,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: _buildMenuItem(
                            context,
                            icon: Icons.category_outlined,
                            title: 'Kelola Kategori',
                            route: AppRoutes.manageCategories,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: _buildMenuItem(
                            context,
                            icon: Icons.view_carousel_outlined,
                            title: 'Kelola Banner',
                            route: AppRoutes.manageBanners,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: _buildMenuItem(
                            context,
                            icon: Icons.store_outlined,
                            title: 'Kelola Toko Cabang',
                            route: AppRoutes.manageStores,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: _buildMenuItem(
                            context,
                            icon: Icons.receipt_long_outlined,
                            title: 'Kelola Transaksi',
                            route: AppRoutes.manageTransactions,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: _buildMenuItem(
                            context,
                            icon: Icons.local_offer_outlined,
                            title: 'Kelola Kupon',
                            route: AppRoutes.manageCoupons,
                          ),
                        ),
                      ],
                    ),
                  _buildMenuItem(
                    context,
                    icon: Icons.search,
                    title: 'Search Menu',
                    route: AppRoutes.products,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.shopping_cart_outlined,
                    title: 'Shop Cart',
                    route: AppRoutes.cart,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.favorite_border,
                    title: 'Wishlist',
                    route: AppRoutes.wishlist,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notifications (2)',
                    route: AppRoutes.notifications,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.store_outlined,
                    title: 'Store Locations',
                    route: AppRoutes.storeLocation,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.delivery_dining_outlined,
                    title: 'Delivery Tracking',
                    route: AppRoutes.deliveryTracker,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.card_giftcard_outlined,
                    title: 'Rewards',
                    route: AppRoutes.rewards,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.person_outline,
                    title: 'Profile',
                    route: AppRoutes.profile,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.reviews_outlined,
                    title: 'Order Review',
                    route: AppRoutes.orderReview, // ✅ Ganti ini
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.message_outlined,
                    title: 'Message',
                    route: AppRoutes.messageList,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.dashboard_customize_outlined,
                    title: 'Elements',
                    route: AppRoutes.products,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Setting',
                    route: AppRoutes.profile, // contoh
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.logout_outlined,
                    title: 'Logout',
                    onTap: () => _handleLogout(context),
                  ),
                ],
              ),
            ),

            const Divider(thickness: 1, height: 1),

            // ====== FOOTER ======
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Biji – Coffee Shop',
                    style: TextStyle(
                      color: Color(0xFF6E4C77),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'App Version 1.0.1',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog before logging out
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog

              // Perform logout using the outer context which is still valid
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();

              // Navigate to login
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.login, (route) => false);
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // ===== WIDGET BUILDER MENU ITEM =====
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? route,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
      onTap: onTap ??
          () {
            if (route != null) {
              _navigateTo(context, route);
            }
          },
    );
  }
}
