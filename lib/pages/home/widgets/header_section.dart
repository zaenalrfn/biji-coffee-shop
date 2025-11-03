import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28.0, left: 16, right: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bagian kiri (teks sapaan)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Good Morning",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Kevin Hard",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Bagian kanan (foto profil + indikator)
          Stack(
            clipBehavior: Clip.none, // <-- 1. TAMBAHKAN INI
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "assets/images/profile1.jpg",
                  width: 45,
                  height: 45,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: -5, // <-- 2. UBAH INI (dari 4 menjadi -5)
                right: -5, // <-- 3. UBAH INI (dari 4 menjadi -5)
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    // <-- 4. TAMBAHKAN BORDER
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white, // Border putih
                      width: 1.5, // Ketebalan border
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
