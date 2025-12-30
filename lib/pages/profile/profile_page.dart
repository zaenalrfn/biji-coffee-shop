import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_side_nav.dart';
import '../../data/models/wishlist_item_model.dart';
import '../../data/services/wishlist_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final WishlistService _wishlistService = WishlistService();
  List<WishlistItem> _wishlistItems = [];
  bool _isLoadingWishlist = true;

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  Future<void> _fetchWishlist() async {
    try {
      final items = await _wishlistService.getWishlist();
      if (mounted) {
        setState(() {
          _wishlistItems = items.take(5).toList();
          _isLoadingWishlist = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingWishlist = false;
        });
      }
    }
  }

  void _toggleDrawer() {
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      Navigator.of(context).pop();
    } else {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;
        return Scaffold(
          key: _scaffoldKey,
          drawer: const CustomSideNav(),
          backgroundColor: const Color(0xFF6E4C77),
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
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: _toggleDrawer,
              ),
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
                          width: 156,
                          height: 156,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6E4C77),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF90709B), width: 3),
                          ),
                        ),
                        // Lapis 2 - Border gradient oranye/kuning
                        Container(
                          width: 146,
                          height: 146,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFF5C27F),
                                const Color(0xFFF7D9B4),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        // Lapis 3 - Border ungu lagi (antara gradien dan putih)
                        Container(
                          width: 136,
                          height: 136,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6E4C77),
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Lapis 4 - Border putih tipis & Gambar Profil
                        Container(
                          width: 126,
                          height: 126,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: user?.profilePhotoUrl != null
                                ? Image.network(user!.profilePhotoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Image.asset(
                                        'assets/images/profile1.jpg',
                                        fit: BoxFit.cover))
                                : Image.asset(
                                    'assets/images/profile1.jpg',
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        // Badge Poin
                        Positioned(
                          bottom: -2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
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
                                color: Color(0xFF6E4C77),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'Guest', // Dynamic name
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.email,
                            color: Colors.white,
                            size: 14), // Changed to email icon for context
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            ((user != null && user.roles.contains('guest')) ||
                                    (user?.email
                                            ?.toLowerCase()
                                            .contains('guest') ??
                                        false))
                                ? 'Guest Account'
                                : (user?.email ?? 'No User'),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                        _buildActionButton(Icons.edit, Colors.grey.shade400,
                            () {
                          if (user != null &&
                              (user.roles.contains('guest') ||
                                  user.email == 'guest@biji.coffee')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("Guest cannot edit profile")));
                            return;
                          }
                          Navigator.pushNamed(
                            context,
                            '/edit-profile', // Use string directly or AppRoutes constant if imported
                            arguments: {
                              'name': user?.name ?? '',
                              'email': user?.email ?? '',
                              'profilePhotoUrl': user?.profilePhotoUrl,
                            },
                          );
                        }),
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
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
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
                        child: _isLoadingWishlist
                            ? const Center(child: CircularProgressIndicator())
                            : _wishlistItems.isEmpty
                                ? Center(
                                    child: Text(
                                      'No favourite items yet',
                                      style: TextStyle(
                                          color: Colors.grey.shade500),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _wishlistItems.length,
                                    itemBuilder: (context, index) {
                                      final item = _wishlistItems[index];
                                      final product = item.product;

                                      final rawImage = product.imageUrl;
                                      final imagePath = rawImage ??
                                          'assets/images/placeholder.png';

                                      return Dismissible(
                                        key: Key(item.id.toString()),
                                        direction: DismissDirection.endToStart,
                                        background: Container(
                                          alignment: Alignment.centerRight,
                                          padding:
                                              const EdgeInsets.only(right: 20),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: const Icon(Icons.delete,
                                              color: Colors.white),
                                        ),
                                        onDismissed: (direction) async {
                                          try {
                                            setState(() {
                                              _wishlistItems.removeAt(index);
                                            });
                                            await _wishlistService
                                                .removeFromWishlist(product.id);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'Item removed from wishlist')));
                                            }
                                          } catch (e) {
                                            _fetchWishlist();
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          'Failed to remove: $e')));
                                            }
                                          }
                                        },
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/product-detail', // Match AppRoutes
                                              arguments: {
                                                'id': product.id,
                                                'title': product.name,
                                                'price': product.price,
                                                'image': product.imageUrl,
                                                'description':
                                                    product.description,
                                              },
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 16),
                                            child: _buildFavouriteMenu(
                                              image: imagePath,
                                              title: product.name,
                                              category: product.categoryName ??
                                                  'Unknown',
                                              price: '\$${product.price}',
                                              rating: '5.0',
                                              isNetworkImage: rawImage !=
                                                      null &&
                                                  (rawImage.startsWith('http')),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildActionButton(IconData icon, Color color,
      [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: color.withOpacity(0.25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  static Widget _buildFavouriteMenu({
    required String image,
    required String title,
    required String category,
    required String price,
    required String rating,
    bool isNetworkImage = false,
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
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: isNetworkImage
                ? Image.network(
                    image,
                    width: 100,
                    height: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 130,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image),
                    ),
                  )
                : Image.asset(
                    image,
                    width: 100,
                    height: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 130,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image),
                    ),
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
