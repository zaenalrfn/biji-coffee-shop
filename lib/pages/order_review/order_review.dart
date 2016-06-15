import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/order_model.dart';

class OrderReviewPage extends StatefulWidget {
  final Order order;
  const OrderReviewPage({super.key, required this.order});

  @override
  State<OrderReviewPage> createState() => _OrderReviewPageState();
}

class _OrderReviewPageState extends State<OrderReviewPage> {
  int _rating = 4; // default rating 4 bintang (3.0 dari 5)
  final TextEditingController _reviewController = TextEditingController();

  // ================= KONFIGURASI GOOGLE FORM =================
  // Masukkan Link Google Form (bagian sebelum tanda ?)
  final String _formBaseUrl =
      'https://docs.google.com/forms/d/e/1FAIpQLSea9uO4vlm3smngK8U3wi26GgM1BxjUe6TS3H9MlyX0eMcAMQ/viewform';

  // Masukkan ID Entry (Dari link pre-filled)
  final String _entryOrderNumber = 'entry.2147381539'; // ID Order Number
  final String _entryRating = 'entry.2104360282'; // ID Rating (1-5)
  final String _entryReview = 'entry.337778148'; // ID Review
  // ==========================================================

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _launchGoogleForm() async {
    try {
      // Encode data biar aman di URL
      final orderId = Uri.encodeComponent(widget.order.orderNumber.isNotEmpty
          ? widget.order.orderNumber
          : widget.order.id.toString());
      final rating = Uri.encodeComponent(_rating.toString());
      final review = Uri.encodeComponent(_reviewController.text);

      // Susun URL Lengkap
      final fullUrl = '$_formBaseUrl?usp=pp_url'
          '&$_entryOrderNumber=$orderId'
          '&$_entryRating=$rating'
          '&$_entryReview=$review';

      final url = Uri.parse(fullUrl);

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal membuka Google Form')),
          );
        }
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use first product for display
    final firstItem =
        (widget.order.items != null && widget.order.items!.isNotEmpty)
            ? widget.order.items!.first
            : null;
    final product = firstItem?.product;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Write Reviews',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image & Info
              Center(
                child: Column(
                  children: [
                    // Product Image
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey.shade100,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: (product != null && product.imageUrl != null)
                            ? Image.network(
                                product.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image),
                              )
                            : Image.asset(
                                'assets/images/placeholder.png', // Fallback
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.image),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Product Name
                    Text(
                      product?.name ?? 'Order #${widget.order.orderNumber}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Category / Price
                    Text(
                      'Rp ${widget.order.totalPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Divider
              Divider(color: Colors.grey.shade200, height: 1),

              const SizedBox(height: 24),

              // What do you think?
              const Text(
                'Bagaimana pengalamanmu?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                'Berikan penilaianmu tentang kualitas produk dan layanan kami agar kami dapat terus berkembang menjadi lebih baik.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // Star Rating & Score
              Row(
                children: [
                  // Stars
                  Row(
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: const Color(0xFFFF8C42),
                            size: 32,
                          ),
                        ),
                      );
                    }),
                  ),

                  const Spacer(),

                  // Score
                  Text(
                    _rating.toDouble().toStringAsFixed(1), // Fix logic here
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Review Text Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _reviewController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Write your review here',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      // Submit Button (Fixed at bottom)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            // Handle submit review
            if (_reviewController.text.isNotEmpty) {
              _launchGoogleForm(); // Launch Google Form
              /*
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Redirecting to Google Form...'),
                  backgroundColor: Colors.green,
                ),
              );
              */
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please write your review'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007AFF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Text(
            'SUBMIT REVIEW',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
