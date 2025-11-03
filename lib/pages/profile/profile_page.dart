import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6E4C77), // warna ungu latar header
      appBar: AppBar(
        backgroundColor: const Color(0xFF6E4C77),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.more_vert, color: Colors.white),
          )
        ],
      ),
      body: Column(
        children: [
          // === HEADER SECTION ===
          Container(
            color: const Color(0xFF6E4C77),
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              children: [
                // Foto profil dengan border berlapis 4 warna
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Lapis 1 - Border ungu terluar (paling tebal)
                    Container(
                      width: 156, // Diameter total untuk border terluar
                      height: 156,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6E4C77), // Warna ungu latar
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF90709B),
                            width:
                                3), // Border ungu yang lebih terang (sesuai gambar)
                      ),
                    ),
                    // Lapis 2 - Border gradient oranye/kuning
                    Container(
                      width: 146, // Sedikit lebih kecil dari lapis 1
                      height: 146,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF5C27F), // Warna oranye terang
                            const Color(0xFFF7D9B4), // Warna kuning krem
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    // Lapis 3 - Border ungu lagi (antara gradien dan putih)
                    Container(
                      width: 136, // Sedikit lebih kecil dari lapis 2
                      height: 136,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6E4C77), // Warna ungu latar
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Lapis 4 - Border putih tipis & Gambar Profil
                    Container(
                      width: 126, // Diameter gambar profil + border putih
                      height: 126,
                      decoration: BoxDecoration(
                        color: Colors.white, // Border putih
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/profile1.jpg', // Pastikan path ini benar
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Badge Poin
                    Positioned(
                      bottom: -2, // Sesuaikan posisi ke bawah
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            // Tambahkan shadow untuk badge poin
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          '456 Pts',
                          style: TextStyle(
                            color: Color(0xFF6E4C77), // warna ungu
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Text(
                  'Kevin Hard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.circle, color: Colors.green, size: 10),
                    SizedBox(width: 6),
                    Text(
                      'London, England',
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 26),

                // Tombol aksi
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(Icons.phone, Colors.white),
                    const SizedBox(width: 20),
                    _buildActionButton(Icons.location_on, Colors.white),
                    const SizedBox(width: 20),
                    _buildActionButton(Icons.email, Colors.white),
                    const SizedBox(width: 20),
                    _buildActionButton(Icons.edit, Colors.grey.shade400),
                  ],
                ),
              ],
            ),
          ),

          // === BAGIAN FAVORITE MENUS ===
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Favourite Menus',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildFavouriteMenu(
                          image:
                              'assets/images/bg1.jpg', // Ganti dengan gambar yang sesuai
                          title: 'Brewed Cappuccino Latte with Creamy Milk',
                          category: 'Food',
                          price: '\$5.8',
                          rating: '4.0',
                        ),
                        const SizedBox(height: 16),
                        _buildFavouriteMenu(
                          image:
                              'assets/images/bg1.jpg', // Ganti dengan gambar yang sesuai
                          title: 'Melted Omelette with Spicy Chilli',
                          category: 'Food',
                          price: '\$8.2',
                          rating: '4.0',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === Tombol Aksi ===
  static Widget _buildActionButton(IconData icon, Color color) {
    return Container(
      width: 58, // Sedikit lebih kecil
      height: 58, // Sedikit lebih kecil
      decoration: BoxDecoration(
        color: color.withOpacity(0.25),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }

  // === Favorite Menu Item ===
  static Widget _buildFavouriteMenu({
    required String image,
    required String title,
    required String category,
    required String price,
    required String rating,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Gambar dengan border radius di semua sisi
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              image,
              width: 100,
              height: 130,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '•',
                        style: TextStyle(
                          color: Colors.black45,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.star,
                          size: 16, color: Colors.amberAccent),
                      const SizedBox(width: 4),
                      Text(
                        rating,
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
          ),
        ],
      ),
    );
  }
}
