import 'package:flutter/material.dart';
import '../core/routes/app_routes.dart'; // pastikan path sesuai dengan lokasi file routes kamu

class CustomSideNav extends StatelessWidget {
  const CustomSideNav({super.key});

  // Fungsi navigasi
  void _navigateTo(BuildContext context, String routeName) {
    Navigator.pop(context); // tutup drawer dulu
    Navigator.pushNamed(context, routeName); // lalu pindah halaman
  }

  @override
  Widget build(BuildContext context) {
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
                    route: AppRoutes.products, // sementara arahkan ke products
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
  route: AppRoutes.storeLocation,  // ✅ BENAR
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
                    route: AppRoutes.products,
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
                    route: AppRoutes.login,
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

  // ===== WIDGET BUILDER MENU ITEM =====
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
      onTap: () => _navigateTo(context, route),
    );
  }
}
