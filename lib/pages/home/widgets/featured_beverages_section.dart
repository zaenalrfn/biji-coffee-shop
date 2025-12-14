import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '/core/routes/app_routes.dart';
import '../../../../providers/product_provider.dart';
import '../../../../providers/cart_provider.dart';
import '../../products/detail_product_page.dart'; // Import Detail Page

class FeaturedBeveragesSection extends StatelessWidget {
  const FeaturedBeveragesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(builder: (context, provider, _) {
      final products = provider.products.take(5).toList(); // Show top 5

      if (provider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header tetap di-padding agar sejajar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Featured Beverages',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3E2B47), // Dark Title
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.products);
                  },
                  child: const Text(
                    'More',
                    style: TextStyle(
                      color: Color(0xFF3E2B47), // Dark "More"
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 🔹 Area swipe — card keluar padding dengan OverflowBox
          SizedBox(
            height: 245,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return OverflowBox(
                  maxWidth:
                      constraints.maxWidth + 3, // tambah 16 kiri + 16 kanan
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    clipBehavior: Clip.none, // biar gak ke-clip
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];

                      // Construct Map for Detail Page
                      final productMap = {
                        'id': product.id,
                        'title': product.name,
                        'price': product.price,
                        'image': product.imageUrl,
                        'description': product.description,
                        'category': product.categoryName,
                      };

                      return GestureDetector(
                        onTap: () {
                          // Navigate to Detail Page
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 300),
                              reverseTransitionDuration:
                                  const Duration(milliseconds: 300),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                final curvedAnimation = CurvedAnimation(
                                    parent: animation, curve: Curves.easeInOut);
                                return FadeTransition(
                                  opacity: curvedAnimation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.05),
                                      end: Offset.zero,
                                    ).animate(curvedAnimation),
                                    child: child,
                                  ),
                                );
                              },
                              pageBuilder: (_, __, ___) =>
                                  ProductDetailPage(product: productMap),
                            ),
                          );
                        },
                        child: Container(
                          width: 170,
                          margin: const EdgeInsets.only(right: 14),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: product.imageUrl != null
                                          ? Image.network(
                                              product.imageUrl!,
                                              height: 130,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (ctx, err, _) =>
                                                  Container(
                                                      height: 130,
                                                      color: Colors.grey[200],
                                                      child: Icon(
                                                          Icons.broken_image)),
                                            )
                                          : Image.asset(
                                              'assets/images/drink1.jpg',
                                              height: 130,
                                              width: double.infinity,
                                              fit: BoxFit.cover),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 10, 10, 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.categoryName ?? 'Beverage',
                                            style: TextStyle(
                                              color: Colors.grey
                                                  .shade600, // Grey Category
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            product.name.isEmpty
                                                ? 'Unnamed Product'
                                                : product.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16, // Larger font
                                              height: 1.3,
                                              color: Color(
                                                  0xFF3E2B47), // Dark Title
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Text(
                                                '\$${product.price}',
                                                style: const TextStyle(
                                                  color: Color(
                                                      0xFF3E2B47), // Dark Price
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              const Text(
                                                '•',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              const Icon(
                                                Icons.star,
                                                size: 16,
                                                color: Colors.amber,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '4.5', // Mock rating
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 🛒 Tombol ke cart
                              Positioned(
                                bottom: 90,
                                right: 14,
                                child: GestureDetector(
                                  onTap: () async {
                                    try {
                                      await Provider.of<CartProvider>(context,
                                              listen: false)
                                          .addToCart(product.id, 1);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    '${product.name} added to cart!')));
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Failed to add to cart: $e')));
                                      }
                                    }
                                  },
                                  child: Container(
                                    height: 46,
                                    width: 46,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          16), // Rounder logic
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.shopping_bag_outlined,
                                      color: Color(0xFF3E2B47), // Dark Icon
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
