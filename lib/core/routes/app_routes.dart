import 'package:flutter/material.dart';

// =================== IMPORT SEMUA PAGE ===================

// Halaman utama dan autentikasi
import '../../pages/onboarding/onboarding_page.dart';
import '../../pages/welcome/welcome_page.dart';
import '../../pages/auth/login_page.dart';
import '../../pages/auth/register_page.dart';
import '../../pages/home/home_page.dart';
import '../../pages/cart/cart_page.dart';
import '../../pages/rewards/rewards_page.dart';
import '../../pages/profile/profile_page.dart';
import '../../pages/products/products_page.dart';
import '../../pages/products/detail_product_page.dart';
import '../../pages/wishlist/wishlist_page.dart';
// Halaman notifikasi
import '../../pages/notification/notification_page.dart';

// Halaman pesan & chat
import '../../pages/messages/message_list_page.dart';
import '../../pages/messages/chat_detail_page.dart';

// Halaman pelacakan pesanan
import '../../pages/tracker/delivery_tracker_page.dart';

import '../../pages/order_review/order_review.dart';

// Halaman lokasi toko
import '../../pages/store_location/store_location_page.dart';
// Halaman checkout
import '../../pages/checkout/checkout_payment_method_page.dart';
import '../../pages/checkout/checkout_shipping_address_page.dart';
import '../../pages/checkout/checkout_coupon_apply_page.dart';
import '../../pages/profile/edit_profile_page.dart';

// Product Management
import '../../pages/admin/manage_products_page.dart';
import '../../pages/admin/add_edit_product_page.dart';
import '../../data/models/product_model.dart';

// Category Management
import '../../pages/admin/manage_categories_page.dart';
import '../../pages/admin/add_edit_category_page.dart';
import '../../data/models/category_model.dart';
// Banner Management
import '../../pages/admin/manage_banners_page.dart';
import '../../pages/admin/add_edit_banner_page.dart';
import '../../data/models/banner_model.dart';
// Store Management
import '../../pages/admin/manage_stores_page.dart';
import '../../pages/admin/add_edit_store_page.dart';
import '../../data/models/store_model.dart';
import '../../pages/admin/manage_transactions_page.dart';
import '../../pages/admin/transaction_detail_page.dart';
import '../../data/models/order_model.dart';

// Coupon Management
import '../../pages/admin/manage_coupons_page.dart';
import '../../pages/admin/add_edit_coupon_page.dart';
import '../../pages/orders/my_orders_page.dart';
import '../../pages/driver/driver_dashboard_page.dart'; // Driver Page
import '../../pages/admin/manage_orders_page.dart'; // Admin Orders Page

// =========================================================

class AppRoutes {
// ...
// (Imports are at top, but I'm replacing near header_section if using multi_replace or use replace with big chunk)
// Check imports first

  // =================== DAFTAR ROUTE NAME ===================

  // Umum
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  // Fitur utama
  static const String cart = '/cart';
  static const String rewards = '/rewards';
  static const String profile = '/profile';
  static const String products = '/products';
  static const String productDetail = '/product-detail';
  static const String notifications = '/notifications';
  //Wishlist
  static const String wishlist = '/wishlist';
  // Pesan & Chat
  static const String messageList = '/messages';
  static const String chatDetail = '/chat-detail';

  // Pelacakan
  static const String deliveryTracker = '/tracker';
  static const String orderReview = '/order-review';

  // Lokasi Toko
  static const String storeLocation = '/store-location';
  // Checkout Pages
  static const String checkoutPayment = '/checkout-payment';
  static const String checkoutShipping = '/checkout-shipping';
  static const String checkoutCoupon = '/checkout-coupon';
  static const String editProfile = '/edit-profile';
  static const String myOrders = '/my-orders';
  static const String driverDashboard = '/driver-dashboard'; // New Route

  // Admin
  static const String manageProducts = '/manage-products';
  static const String addEditProduct = '/add-edit-product';
  static const String manageCategories = '/manage-categories';
  static const String addEditCategory = '/add-edit-category';
  static const String manageBanners = '/manage-banners';
  static const String addEditBanner = '/add-edit-banner';
  static const String manageStores = '/manage-stores';
  static const String manageOrders = '/manage-orders'; // New Route

  static const String addEditStore = '/add-edit-store';

  static const String manageTransactions = '/manage-transactions';
  static const String transactionDetail = '/transaction-detail';

  static const String manageCoupons = '/manage-coupons'; // New
  static const String addEditCoupon = '/add-edit-coupon'; // New
  // ==========================================================

  // =================== GENERATE ROUTE =======================
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ===== Onboarding & Welcome =====
      case '/':
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomePage());

      // ===== Autentikasi =====
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      // ===== Halaman Utama =====
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case cart:
        return MaterialPageRoute(builder: (_) => const CartPage());
      case rewards:
        return MaterialPageRoute(builder: (_) => const RewardsPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case products:
        return MaterialPageRoute(builder: (_) => const ProductsPage());
      case productDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: args));
//==== Wishlist ====
      case wishlist:
        return MaterialPageRoute(builder: (_) => const WishlistPage());

      // ===== Notifikasi =====
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationPage());

      // ===== Pesan & Chat =====
      case messageList:
        return MaterialPageRoute(builder: (_) => const MessageListPage());
      case chatDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ChatDetailPage(
            userName: args?['name'] ?? 'Chat',
            userAvatar: args?['avatar'] ?? 'assets/images/profile1.jpg',
            userId: args?['id'] ?? 'ID 2445556',
          ),
        );

      // ===== Pelacakan =====
      case deliveryTracker:
        return MaterialPageRoute(
          builder: (_) => const DeliveryTrackerPage(),
          settings: settings, // IMPORTANT: Pass arguments!
        );
      case orderReview:
        final order = settings.arguments as Order;
        return MaterialPageRoute(builder: (_) => OrderReviewPage(order: order));

      // ===== Lokasi Toko =====
      case storeLocation:
        return MaterialPageRoute(builder: (_) => const StoreLocationPage());
      case checkoutPayment:
        return MaterialPageRoute(
            builder: (_) => const CheckoutPaymentMethodPage());
      case checkoutShipping:
        return MaterialPageRoute(
            builder: (_) => const CheckoutShippingAddressPage());
      case checkoutCoupon:
        return MaterialPageRoute(
            builder: (_) => const CheckoutCouponApplyPage());
      case editProfile:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => EditProfilePage(
            initialName: args?['name'] ?? '',
            initialEmail: args?['email'] ?? '',
            initialPhotoUrl: args?['profilePhotoUrl'],
          ),
        );

      // ===== Admin =====
      case manageProducts:
        return MaterialPageRoute(builder: (_) => const ManageProductsPage());
      case addEditProduct:
        final args = settings.arguments as Product?;
        return MaterialPageRoute(
            builder: (_) => AddEditProductPage(product: args));

      case manageCategories:
        return MaterialPageRoute(builder: (_) => const ManageCategoriesPage());
      case addEditCategory:
        final args = settings.arguments as Category?;
        return MaterialPageRoute(
            builder: (_) => AddEditCategoryPage(category: args));

      case manageBanners:
        return MaterialPageRoute(builder: (_) => const ManageBannersPage());
      case addEditBanner:
        final args = settings.arguments as BannerModel?;
        return MaterialPageRoute(
            builder: (_) => AddEditBannerPage(banner: args));

      case manageStores:
        return MaterialPageRoute(builder: (_) => const ManageStoresPage());
      case manageOrders:
        return MaterialPageRoute(builder: (_) => const ManageOrdersPage());
      case addEditStore:
        final args = settings.arguments as StoreModel?;
        return MaterialPageRoute(builder: (_) => AddEditStorePage(store: args));

      case manageTransactions:
        return MaterialPageRoute(
            builder: (_) => const ManageTransactionsPage());
      case transactionDetail:
        final args = settings.arguments as Order;
        return MaterialPageRoute(
            builder: (_) => TransactionDetailPage(order: args));

      case manageCoupons:
        return MaterialPageRoute(builder: (_) => const ManageCouponsPage());
      case addEditCoupon:
        return MaterialPageRoute(builder: (_) => const AddEditCouponPage());

      case myOrders:
        return MaterialPageRoute(builder: (_) => const MyOrdersPage());

      // ===== Default (404 Page) =====
      case driverDashboard:
        return MaterialPageRoute(builder: (_) => const DriverDashboardPage());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
  // ==========================================================
}
