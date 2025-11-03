import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class FeaturedBeveragesSection extends StatelessWidget {
  const FeaturedBeveragesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> beverages = List.generate(4, (index) {
      return {
        'image': 'assets/images/drink1.jpg',
        'category': 'Tea',
        'name': 'Hot Sweet Indonesian Tea',
        'price': 5.8,
        'rating': 4.5,
      };
    });

    return Padding(
      // ✅ Sama kayak CategorySection
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured Beverages',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'More',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // --- List Produk ---
          SizedBox(
            height: 245,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: beverages.length,
              itemBuilder: (context, index) {
                final item = beverages[index];
                return Container(
                  width: 170,
                  margin: EdgeInsets.only(
                    right: index == beverages.length - 1 ? 0 : 14,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none, // ⬅️ biar ikon bisa keluar batas
                    children: [
                      // --- Card Utama ---
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
                            // --- Gambar Produk ---
                            ClipRRect(
                              // ✅ Bikin semua sisi tumpul
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                item['image'],
                                height: 130,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),

                            // --- Detail Produk ---
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 10, 10, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['category'],
                                    style: const TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['name'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  // --- Harga + Rating ---
                                  Row(
                                    children: [
                                      Text(
                                        '\$${item['price']}',
                                        style: const TextStyle(
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.bold,
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
                                        item['rating'].toString(),
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

                      // --- Tombol Keranjang ---
                      Positioned(
                        bottom:
                            90, // ⬇️ NEGATIF = sebagian keluar dari card (atur lebih besar untuk turun lebih jauh)
                        right: 14,
                        child: Container(
                          height: 46, // ⬆️ Besarkan tombol di sini
                          width: 46,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                                12), // ⬆️ Sudut lebih tumpul
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            color: AppColors.primary,
                            size: 26, // ⬆️ Ubah ukuran ikon
                          ),
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
