import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/banner_provider.dart';

class PromotionSection extends StatelessWidget {
  const PromotionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Header tetap di-padding agar sejajar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
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
        ),

        const SizedBox(height: 12),

        // 🔹 Area swipe — gambar keluar padding
        SizedBox(
          height: 190,
          child: Consumer<BannerProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.banners.isEmpty) {
                // Return generic banner if empty or just empty container
                return const Center(child: Text("No Promotions Available"));
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  return OverflowBox(
                    maxWidth:
                        constraints.maxWidth + 3, // nambah 16 kiri + 16 kanan
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      clipBehavior: Clip.none, // biar gak ke-clip
                      itemCount: provider.banners.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final banner = provider.banners[index];
                        return _promoCard(banner.imageUrl);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _promoCard(String? imageUrl) {
    return Container(
      width: 325,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.grey[300], // Placeholder color
        image: (imageUrl != null && imageUrl.isNotEmpty)
            ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
                onError:
                    (_, __) {}, // Handle error silently or show placeholder
              )
            : const DecorationImage(
                image:
                    AssetImage("assets/images/promosi.png"), // Fallback/Default
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
    );
  }
}
