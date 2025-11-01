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
            height: 190,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _promoCard(
                  "assets/images/pic1.png",
                  "Hot Mocha Cappuccino Latte",
                  "\$5.8",
                  "\$9.9",
                  const Color(0xFF4B3B47),
                ),
                _promoCard(
                  "assets/images/pic1.png",
                  "Hot Sweet Tea Indonesia",
                  "\$2.5",
                  "\$3.5",
                  const Color(0xFFE74C3C),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _promoCard(
    String productImage,
    String title,
    String price,
    String oldPrice,
    Color bgColor,
  ) {
    return Container(
      width: 275,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        image: const DecorationImage(
          image: AssetImage("assets/images/card-bg.png"),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gambar produk kanan — diperbesar
          Positioned(
            right: 8,
            top: 25,
            bottom: 25,
            child: Image.asset(
              productImage,
              width: 115, // dibesarkan dari 100 -> 115
              fit: BoxFit.contain,
            ),
          ),

          // Isi teks dan harga
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28), // lebih turun lagi
                SizedBox(
                  width: 150,
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12), // harga lebih naik lagi
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          oldPrice,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
