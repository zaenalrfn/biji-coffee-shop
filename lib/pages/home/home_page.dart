import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'widgets/header_section.dart';
import 'widgets/promotion_section.dart';
import 'widgets/category_section.dart';
import 'widgets/featured_beverages_section.dart';

import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/banner_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      final bannerProvider =
          Provider.of<BannerProvider>(context, listen: false);

      productProvider.fetchProductsAndCategories();
      bannerProvider.fetchBanners();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        onTap: (index) {
          // Navigation is handled inside CustomBottomNav.
          // We don't need to update state here because other items open new pages.
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              HeaderSection(),
              SizedBox(height: 20),
              PromotionSection(),
              SizedBox(height: 25),
              CategorySection(),
              SizedBox(height: 25),
              FeaturedBeveragesSection(), // tambahkan di sini
            ],
          ),
        ),
      ),
    );
  }
}
