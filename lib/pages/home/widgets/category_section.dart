import 'package:flutter/material.dart';

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

          // Scroll horizontal
          SizedBox(
            height: 145, // <--- Diubah dari 130 menjadi 145
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final c = categories[index];
                return Container(
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
                  // MENGGANTI CHILD DARI CONTAINER INI DENGAN STACK
                  child: Stack(
                    children: [
                      // --- Icon Ornamen di Pojok Kanan Bawah ---
                      Positioned(
                        right:
                            -10, // Dorong sedikit ke luar agar hanya pojoknya terlihat
                        bottom: -10, // Dorong sedikit ke luar
                        child: Icon(
                          c["icon"] as IconData,
                          size: 100, // Ukuran icon ornamen yang lebih besar
                          color: Colors.white.withOpacity(
                              0.1), // Transparan agar tidak terlalu menonjol
                        ),
                      ),

                      // --- Konten Asli Card (Icon, Title, Menu) ---
                      Padding(
                        padding: const EdgeInsets.all(16), // Padding ini tetap
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // rata kiri
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
