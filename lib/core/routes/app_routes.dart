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
// =========================================================

class AppRoutes {
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

  // Admin
  static const String manageProducts = '/manage-products';
  static const String addEditProduct = '/add-edit-product';
  static const String manageCategories = '/manage-categories';
  static const String addEditCategory = '/add-edit-category';
  static const String manageBanners = '/manage-banners';
  static const String addEditBanner = '/add-edit-banner';
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
        return MaterialPageRoute(builder: (_) => const DeliveryTrackerPage());
      case orderReview:
        return MaterialPageRoute(builder: (_) => const OrderReviewPage());

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

      // ===== Default (404 Page) =====
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                'Page not found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        );
    }
  }
  // ==========================================================
}
