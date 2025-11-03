import 'package:flutter/material.dart';

class PromotionSection extends StatelessWidget {
  const PromotionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16), // sejajar header
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Promotion",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "More",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Scroll horizontal cards
          SizedBox(
            height: 190, // Ukuran card tetap sama
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // --- DIUBAH MENJADI 3 KARTU ---
                _promoCard(),
                _promoCard(),
                _promoCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi _promoCard (Tetap sama)
  Widget _promoCard() {
    return Container(
      width: 325, // Ukuran card tetap sama
      margin: const EdgeInsets.only(right: 16), // Margin tetap sama
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18), // Radius tetap sama
        image: const DecorationImage(
          // Menggunakan gambar promosi baru Anda
          image: AssetImage("assets/images/promosi.png"),
          fit: BoxFit.cover, // Memastikan gambar memenuhi seluruh card
        ),
        boxShadow: [
          // Shadow tetap sama
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Tidak ada child (Stack, Teks, Harga dihapus)
    );
  }
}
