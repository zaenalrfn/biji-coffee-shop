import 'package:flutter/material.dart';
import '../../data/models/wishlist_item_model.dart';
import '../../data/services/wishlist_service.dart';
import '../products/detail_product_page.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final WishlistService _wishlistService = WishlistService();
  final TextEditingController _searchController = TextEditingController();

  List<WishlistItem> _wishlistItems = [];
  List<WishlistItem> _filteredItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchWishlist() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final items = await _wishlistService.getWishlist();
      setState(() {
        _wishlistItems = items;
        _filteredItems = items;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load wishlist: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterWishlist(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredItems = _wishlistItems;
      });
    } else {
      setState(() {
        _filteredItems = _wishlistItems
            .where((item) =>
                item.product.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  Future<void> _removeFromWishlist(WishlistItem item) async {
    try {
      // Optimistic update
      setState(() {
        _wishlistItems.remove(item);
        _filterWishlist(_searchController.text);
      });

      // API Call
      await _wishlistService.removeFromWishlist(item.productId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from wishlist')),
      );
    } catch (e) {
      // Revert if failed
      setState(() {
        _wishlistItems.add(item);
        _filterWishlist(_searchController.text);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Wishlist',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.more_vert, color: Colors.black, size: 26),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
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
                  Icon(Icons.search, color: Colors.grey.shade400, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterWishlist,
                      decoration: InputDecoration(
                        hintText: "Search Here",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // List Items
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? Center(
                        child: Text(
                          "Your wishlist is empty",
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          final product = item.product;

                          // Handle image
                          final rawImage = product.imageUrl;
                          final bool isNetworkImage = rawImage != null &&
                              (rawImage.startsWith('http') ||
                                  rawImage.startsWith('https'));
                          final String imagePath =
                              rawImage ?? 'assets/images/placeholder.png';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  // Navigate to Detail Product
                                  // Reconstruct map as DetailProductPage expects a Map<String, dynamic>
                                  final productMap = {
                                    'id': product.id,
                                    'title': product.name,
                                    'subtitle': product.subtitle,
                                    'description': product.description,
                                    'price': product.price,
                                    'image': product.imageUrl,
                                    'category_id': product.categoryId,
                                    'category': {'name': product.categoryName},
                                  };

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailPage(
                                          product: productMap),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: isNetworkImage
                                            ? Image.network(
                                                imagePath,
                                                width: 70,
                                                height: 70,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (context, error, stack) {
                                                  return Container(
                                                    width: 70,
                                                    height: 70,
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                        Icons.broken_image),
                                                  );
                                                },
                                              )
                                            : Image.asset(
                                                imagePath,
                                                width: 70,
                                                height: 70,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (context, error, stack) =>
                                                        Container(
                                                  width: 70,
                                                  height: 70,
                                                  color: Colors.grey[200],
                                                ),
                                              ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              product.subtitle != null &&
                                                      product
                                                          .subtitle!.isNotEmpty
                                                  ? "Variant : ${product.subtitle}"
                                                  : (product.categoryName !=
                                                          null
                                                      ? "Category : ${product.categoryName}"
                                                      : ""),
                                              style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 13,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "\$${product.price.toStringAsFixed(2)}",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Delete Button (Love Icon)
                                      GestureDetector(
                                        onTap: () => _removeFromWishlist(item),
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.favorite,
                                            color: Color(0xFF4A2C2A),
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
