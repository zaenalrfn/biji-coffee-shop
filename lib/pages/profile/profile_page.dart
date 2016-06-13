import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/custom_side_nav.dart';
import '../../core/constants/api_constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _userName = 'Loading...';
  String _userEmail = 'Loading...';
  // String _userAvatar = 'assets/images/profile1.jpg'; // Pending API

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      // Handle not logged in case if needed
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.userEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // Adjust keys based on actual API response structure
          _userName = data['name'] ?? 'User';
          _userEmail = data['email'] ?? 'No Email';
        });
      } else {
        // Handle error (e.g., token expired)
        if (response.statusCode == 401) {
          _logout();
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');

    // Optional: Call logout API endpoint if exists

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _logout();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
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
                        child: Image.asset(
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
                  _userName, // Dynamic name
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
                    Text(
                      _userEmail, // Dynamic email
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 15),
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
                          image: 'assets/images/bg1.jpg',
                          title: 'Brewed Cappuccino Latte with Creamy Milk',
                          category: 'Food',
                          price: '\$5.8',
                          rating: '4.0',
                        ),
                        const SizedBox(height: 16),
                        _buildFavouriteMenu(
                          image: 'assets/images/bg1.jpg',
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

  static Widget _buildActionButton(IconData icon, Color color) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: color.withOpacity(0.25),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }

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
