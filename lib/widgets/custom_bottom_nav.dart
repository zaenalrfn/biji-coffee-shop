import 'package:flutter/material.dart';
import '../core/routes/app_routes.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFF4B3B47);
    const Color inactiveColor = Colors.black26;

    final List<IconData> icons = [
      Icons.home_outlined,
      Icons.shopping_bag_outlined,
      Icons.storefront_outlined,
      Icons.person_outline,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (index) {
          final bool isActive = index == currentIndex;

          return GestureDetector(
            onTap: () => _handleNavigation(context, index),
            behavior: HitTestBehavior.translucent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icons[index],
                  color: isActive ? activeColor : inactiveColor,
                  size: 28,
                ),
                const SizedBox(height: 4),
                // Titik kecil di bawah icon aktif
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? activeColor : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        // Home - tidak perlu navigasi karena sudah di home
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.cart);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.rewards);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.profile);
        break;
    }
    onTap(index);
  }
}
