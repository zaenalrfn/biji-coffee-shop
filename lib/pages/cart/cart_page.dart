import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../data/cart_data.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _removeItem(Map<String, dynamic> item, List<Map<String, dynamic>> list) {
    setState(() {
      cartItems.remove(item);
      list.remove(item);
    });
  }

  List<Map<String, dynamic>> _filterItems(String status) {
    if (status == "All") return List.from(cartItems);
    return cartItems.where((item) => item["status"] == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cart',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      // 🧾 Tombol bawah
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(30),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3E2B47),
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            "PLACE ORDER",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Color(0xFF9E9E9E)),
                  hintText: "Search Order ID or Product",
                  hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          // 🧭 Custom TabBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                labelPadding: EdgeInsets.zero,
                indicatorPadding:
                    const EdgeInsets.symmetric(horizontal: -20, vertical: 4),
                tabs: [
                  _buildAnimatedTab("All", 0),
                  _buildAnimatedTab("Delivery", 1),
                  _buildAnimatedTab("Done", 2),
                ],
              ),
            ),
          ),

          // 📄 Konten tiap tab dengan efek swipe + animasi fade-slide
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: 3,
              onPageChanged: (index) {
                _tabController.animateTo(index);
              },
              itemBuilder: (context, index) {
                final status = ["All", "Delivery", "Done"][index];
                final items = _filterItems(status);

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) {
                    final fade =
                        CurvedAnimation(parent: animation, curve: Curves.ease);
                    final slide = Tween<Offset>(
                      begin: const Offset(0.1, 0),
                      end: Offset.zero,
                    ).animate(animation);

                    return FadeTransition(
                      opacity: fade,
                      child: SlideTransition(
                        position: slide,
                        child: child,
                      ),
                    );
                  },
                  child: _buildCartList(
                    items,
                    key: ValueKey(status),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🟢 Tab Item dengan animasi padding lembut
  Widget _buildAnimatedTab(String text, int index) {
    final bool isActive = _tabController.index == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(
        horizontal: isActive ? 20 : 14,
        vertical: isActive ? 8 : 6,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: isActive ? Colors.black : Colors.black54,
        ),
      ),
    );
  }

  // 🧺 Daftar isi cart
  Widget _buildCartList(List<Map<String, dynamic>> items, {Key? key}) {
    if (items.isEmpty) {
      return const Center(
        child: Text("No items found", style: TextStyle(color: Colors.black54)),
      );
    }

    return ListView.builder(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Slidable(
              key: ValueKey(item['title']),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.25,
                children: [
                  SlidableAction(
                    onPressed: (context) => _removeItem(item, items),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        item['image'],
                        width: 120,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Bagian kanan (judul + harga)
                    Expanded(
                      child: SizedBox(
                          height:
                              150, // tinggi sama seperti gambar agar bisa spaceBetween
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween, // penting
                              children: [
                                // Judul
                                Text(
                                  item['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 19,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                // Harga, qty, total
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "\$${item['price']}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "${item['quantity']}x",
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "\$${item['total']}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                    ),
                  ],
                ),
              )),
        );
      },
    );
  }
}
