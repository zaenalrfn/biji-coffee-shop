import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../data/models/cart_item_model.dart';
import '../../../core/routes/app_routes.dart';
import '../../widgets/custom_side_nav.dart'; // import

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Key for Scaffold

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

    // Fetch cart data from API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).fetchCart();
    });
  }

  // Filter items based on tab status.
  // Since API CartItem usually represents "active cart", we treat "All" as valid.
  // "Delivery" and "Done" are placeholders for Order History in this context.
  List<CartItem> _filterItems(String status, List<CartItem> allItems) {
    if (status == "All") return allItems;
    // Return empty for Delivery/Done as Cart API only returns current active cart
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign key
      backgroundColor: Colors.white,
      drawer: const CustomSideNav(), // Add drawer
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
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer(); // Open drawer
            },
          ),
        ],
      ),

      // 🧾 Tombol bawah
      bottomNavigationBar:
          Consumer<CartProvider>(builder: (context, cart, child) {
        return Container(
          padding: const EdgeInsets.all(30),
          color: Colors.white,
          child: ElevatedButton(
            onPressed: cart.cartItems.isEmpty
                ? null
                : () {
                    // Arahkan ke halaman checkout
                    Navigator.pushNamed(context, AppRoutes.checkoutShipping);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3E2B47),
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              disabledBackgroundColor: Colors.grey,
            ),
            child: cart.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text(
                    "PLACE ORDER",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      }),

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
            child: Consumer<CartProvider>(builder: (context, cart, child) {
              if (cart.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return PageView.builder(
                controller: _pageController,
                itemCount: 3,
                onPageChanged: (index) {
                  _tabController.animateTo(index);
                },
                itemBuilder: (context, index) {
                  final status = ["All", "Delivery", "Done"][index];
                  final items = _filterItems(status, cart.cartItems);

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation) {
                      final fade = CurvedAnimation(
                          parent: animation, curve: Curves.ease);
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
              );
            }),
          ),
        ],
      ),
    );
  }

  // 🟢 Tab Item dengan animasi padding lembut
  Widget _buildAnimatedTab(String text, int index) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
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
      },
    );
  }

  // 🧺 Daftar isi cart
  Widget _buildCartList(List<CartItem> items, {Key? key}) {
    if (items.isEmpty) {
      return Center(
        key: key,
        child: const Text("No items found",
            style: TextStyle(color: Colors.black54)),
      );
    }

    return ListView.builder(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final product = item.product;

        if (product == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Slidable(
              key: ValueKey(item.id),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.25,
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      Provider.of<CartProvider>(context, listen: false)
                          .removeFromCart(item.id);
                    },
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
                      child: product.imageUrl != null
                          ? Image.network(
                              product.imageUrl!,
                              width: 120,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 120,
                                height: 150,
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image),
                              ),
                            )
                          : Container(
                              width: 120,
                              height: 150,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image),
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
                                  product.name,
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
                                    // Price
                                    Text(
                                      "\$${product.price}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),

                                    // Qty Controls (Explicit visible buttons)
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 2),
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              if (item.quantity > 1) {
                                                Provider.of<CartProvider>(
                                                        context,
                                                        listen: false)
                                                    .updateCartItem(item.id,
                                                        item.quantity - 1);
                                              }
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child: Icon(Icons.remove,
                                                  size: 16,
                                                  color: Colors.black54),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: Text(
                                              "${item.quantity}",
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Provider.of<CartProvider>(context,
                                                      listen: false)
                                                  .updateCartItem(item.id,
                                                      item.quantity + 1);
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child: Icon(Icons.add,
                                                  size: 16,
                                                  color: Colors.black54),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Total & Delete
                                    Row(
                                      children: [
                                        Text(
                                          "\$${(product.price * item.quantity).toStringAsFixed(1)}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        InkWell(
                                          onTap: () {
                                            Provider.of<CartProvider>(context,
                                                    listen: false)
                                                .removeFromCart(item.id);
                                          },
                                          child: const Icon(
                                              Icons.delete_outline,
                                              size: 20,
                                              color: Colors.red),
                                        ),
                                      ],
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
