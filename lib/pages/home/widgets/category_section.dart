import 'package:flutter/material.dart';
import '../../products/products_page.dart';

import 'package:provider/provider.dart';
import '../../../../providers/product_provider.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final categories = provider.categories;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Categories",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                height: 145,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return OverflowBox(
                      maxWidth: constraints.maxWidth + 3,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        clipBehavior: Clip.none,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          // Count products in this category
                          final count = provider.products
                              .where((p) => p.categoryId == category.id)
                              .length;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductsPage(
                                    selectedCategory: category.name,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 150,
                              margin: const EdgeInsets.only(right: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4B3B47),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    right: -10,
                                    bottom: -10,
                                    child: Icon(
                                      Icons
                                          .coffee, // Default icon since API might not return icon data
                                      size: 100,
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.coffee,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          category.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "$count Menus",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
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
      },
    );
  }
}
