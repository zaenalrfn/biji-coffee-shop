import 'package:flutter/material.dart';
import '../../products/products_page.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {"icon": Icons.local_cafe, "title": "Beverages", "menu": "67 Menus"},
      {"icon": Icons.fastfood, "title": "Foods", "menu": "23 Menus"},
      {"icon": Icons.local_pizza, "title": "Pizza", "menu": "28 Menus"},
      {"icon": Icons.local_drink, "title": "Drink", "menu": "19 Menus"},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16), // sejajar header
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Categories",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Scroll horizontal + navigasi
          SizedBox(
            height: 145,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final c = categories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductsPage(
                          selectedCategory: c["title"] as String,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 150,
                    margin: EdgeInsets.only(
                      right: index == categories.length - 1 ? 0 : 14,
                    ),
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
                        // Ornamen icon besar transparan
                        Positioned(
                          right: -10,
                          bottom: -10,
                          child: Icon(
                            c["icon"] as IconData,
                            size: 100,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),

                        // Konten utama card
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                c["icon"] as IconData,
                                color: Colors.white,
                                size: 30,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                c["title"] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                c["menu"] as String,
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
          ),
        ],
      ),
    );
  }
}
