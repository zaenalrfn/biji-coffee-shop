import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/order_model.dart';
import '../../../core/routes/app_routes.dart';
import '../../widgets/custom_side_nav.dart';

// ... (existing imports but make sure OrderProvider is imported)

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

    // Fetch data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).fetchCart();
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const CustomSideNav(),
      appBar: AppBar(
        // ... (Keep existing AppBar)
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
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
      ),

      // 🧾 Place Order Button only for Cart Tab
      bottomNavigationBar: AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) {
            // Only show button on Tab 0 (Cart)
            if (_tabController.index != 0) return const SizedBox.shrink();

            return Consumer<CartProvider>(builder: (context, cart, child) {
              return Container(
                padding: const EdgeInsets.all(30),
                color: Colors.white,
                child: ElevatedButton(
                  onPressed: cart.cartItems.isEmpty
                      ? null
                      : () {
                          Navigator.pushNamed(
                              context, AppRoutes.checkoutShipping);
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
            });
          }),

      body: Column(
        children: [
          // ... (Search Bar - keep existing)
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

          // 📄 Page View
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                _tabController.animateTo(index);
              },
              children: [
                // 1. Cart Tab
                Consumer<CartProvider>(builder: (context, cart, child) {
                  if (cart.isLoading)
                    return const Center(child: CircularProgressIndicator());
                  return _buildCartList(cart.cartItems);
                }),

                // 2. Delivery Tab (Pending/Paid/Shipped)
                Consumer<OrderProvider>(builder: (context, orderArgs, child) {
                  if (orderArgs.isLoading)
                    return const Center(child: CircularProgressIndicator());

                  // Filter active orders
                  final activeOrders = orderArgs.orders
                      .where((o) =>
                          o.status == 'pending' ||
                          o.status == 'paid' ||
                          o.status == 'shipped' ||
                          o.status == 'processing')
                      .toList();

                  return _buildOrderList(activeOrders);
                }),

                // 3. Done Tab (Completed/Cancelled)
                Consumer<OrderProvider>(builder: (context, orderArgs, child) {
                  if (orderArgs.isLoading)
                    return const Center(child: CircularProgressIndicator());

                  // Filter completed orders
                  final completedOrders = orderArgs.orders
                      .where((o) =>
                          o.status == 'completed' || o.status == 'cancelled')
                      .toList();

                  return _buildOrderList(completedOrders);
                }),
              ],
            ),
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

  // 📦 Order List Widget
  Widget _buildOrderList(List<Order> orders) {
    if (orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await Provider.of<OrderProvider>(context, listen: false)
              .fetchOrders();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            Center(
                child: Text("No orders found",
                    style: TextStyle(color: Colors.grey)))
          ],
        ),
      );
    }

    return RefreshIndicator(
        onRefresh: () async {
          await Provider.of<OrderProvider>(context, listen: false)
              .fetchOrders();
        },
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final order = orders[index];
            final firstItem = (order.items != null && order.items!.isNotEmpty)
                ? order.items!.first
                : null;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          firstItem != null && firstItem.product != null
                              ? firstItem.product!.name
                              : "Order #${order.orderNumber.isNotEmpty ? order.orderNumber : order.id}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order.status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(order.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      )
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      if (firstItem != null &&
                          firstItem.product != null &&
                          firstItem.product!.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            firstItem.product!.imageUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[200], width: 60, height: 60),
                          ),
                        )
                      else
                        Container(
                            color: Colors.grey[200],
                            width: 60,
                            height: 60,
                            child: const Icon(Icons.shopping_bag)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (firstItem != null && firstItem.product != null)
                              Text(firstItem.product!.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                            Text("${order.items?.length ?? 0} Items",
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13)),
                            Text(
                                order
                                    .createdAt, // You might need DateTime parsing here
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text(
                        "Rp ${order.totalPrice.toStringAsFixed(0)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ));
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.blue;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // 🧺 Daftar isi cart (Keep existing)
  Widget _buildCartList(List<CartItem> items, {Key? key}) {
    if (items.isEmpty) {
      return Center(
        key: key,
        child: const Text("Your cart is empty",
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
                                // 1. Judul
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        16, // Sedikit diperkecil agar muat
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                if (item.size != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      "Size: ${item.size}",
                                      style: TextStyle(
                                        color: Colors.brown[400],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 4),

                                // 2. Harga Satuan
                                Text(
                                  "Rp ${product.price.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),

                                const Spacer(),

                                // 3. Baris Bawah: Qty (Kiri) & Total + Hapus (Kanan)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Qty Controls
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

                                    // Total Price only
                                    Text(
                                      "Rp ${(product.price * item.quantity).toStringAsFixed(0)}",
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
