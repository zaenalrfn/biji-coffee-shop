import 'package:flutter/material.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String selectedSize = 'MD';
  int quantity = 1;
  double scrollOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    final String imagePath = product['image'] ?? 'assets/images/placeholder.png';
    final String title = product['title'] ?? 'Produk Tanpa Nama';
    final double price = (product['price'] ?? 0).toDouble();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ========== SCROLL AREA ==========
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.axis == Axis.vertical) {
                setState(() {
                  scrollOffset = notification.metrics.pixels;
                });
              }
              return true;
            },
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 150),
              child: Column(
                children: [
                  // ========== GAMBAR PRODUK DENGAN EFEK PARALLAX ==========
                  Transform.translate(
                    offset: Offset(0, scrollOffset * 0.4),
                    child: Opacity(
                      opacity: (1 - (scrollOffset / 250)).clamp(0.0, 1.0),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                        child: Hero(
                          tag: "product_${product['id'] ?? title}",
                          child: Image.asset(
                            imagePath,
                            width: double.infinity,
                            height: 420,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 320,
                                width: double.infinity,
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image,
                                    size: 60, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ========== KONTEN DETAIL ==========
                  Container(
                    transform: Matrix4.translationValues(0, -25, 0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Title dan deskripsi
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Center(
                            child: Column(children: [
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim minim venia",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  height: 1.5,
                                ),
                              ),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Pilihan Size
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: ['SM', 'MD', 'LG', 'XL']
                              .map((size) => GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedSize = size;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20, horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: selectedSize == size
                                            ? Colors.orange[200]
                                            : Colors.orange[50],
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.orange,
                                        ),
                                      ),
                                      child: Text(
                                        size,
                                        style: TextStyle(
                                          color: selectedSize == size
                                              ? Colors.black
                                              : Colors.grey[700],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 30),

                        // Harga + Qty
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.local_offer_outlined,
                                    color: Colors.orange),
                                const SizedBox(width: 6),
                                Text(
                                  "\$${price.toStringAsFixed(1)}",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _buildQtyButton(Icons.remove, () {
                                  setState(() {
                                    if (quantity > 1) quantity--;
                                  });
                                }),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Text(
                                    quantity.toString(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                _buildQtyButton(Icons.add, () {
                                  setState(() {
                                    quantity++;
                                  });
                                }),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "*)Dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ========== TOMBOL BACK + FAVORITE ==========
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIconButton(Icons.arrow_back, () {
                    Navigator.pop(context);
                  }),
                  const Text(
                    "Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  _buildIconButton(Icons.bookmark_border, () {}),
                ],
              ),
            ),
          ),

          // ========== TOMBOL PLACE ORDER ANIMASI ==========
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            bottom: scrollOffset > 100 ? 0 : -100,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A2C4B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    "PLACE ORDER   \$${(price * quantity).toStringAsFixed(1)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== Widget Tambahan ==========
  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(icon, size: 18, color: Colors.black87),
        ),
      ),
    );
  }
}
