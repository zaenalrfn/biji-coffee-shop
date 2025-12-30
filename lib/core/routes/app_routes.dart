import 'package:flutter/material.dart';

// =================== IMPORT SEMUA PAGE ===================
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
import '../../pages/notification/notification_page.dart';
import '../../pages/messages/message_list_page.dart';
import '../../pages/messages/chat_detail_page.dart';
import '../../pages/tracker/delivery_tracker_page.dart';
import '../../pages/order_review/order_review.dart';
import '../../pages/store_location/store_location_page.dart';
import '../../pages/checkout/checkout_payment_method_page.dart';
import '../../pages/checkout/checkout_shipping_address_page.dart';
import '../../pages/checkout/checkout_coupon_apply_page.dart';
import '../../pages/profile/edit_profile_page.dart';
import '../../pages/admin/manage_products_page.dart';
import '../../pages/admin/add_edit_product_page.dart';
import '../../data/models/product_model.dart';
import '../../pages/admin/manage_categories_page.dart';
import '../../pages/admin/add_edit_category_page.dart';
import '../../data/models/category_model.dart';
import '../../pages/admin/manage_banners_page.dart';
import '../../pages/admin/add_edit_banner_page.dart';
import '../../data/models/banner_model.dart';
import '../../pages/admin/manage_stores_page.dart';
import '../../pages/admin/add_edit_store_page.dart';
import '../../data/models/store_model.dart';
import '../../pages/admin/manage_transactions_page.dart';
import '../../pages/admin/transaction_detail_page.dart';
import '../../data/models/order_model.dart';
import '../../pages/admin/manage_coupons_page.dart';
import '../../pages/admin/add_edit_coupon_page.dart';
import '../../pages/orders/my_orders_page.dart';
import '../../pages/driver/driver_dashboard_page.dart';
import '../../pages/admin/manage_orders_page.dart';

class AppRoutes {
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
  static const String wishlist = '/wishlist';
  static const String messageList = '/messages';
  static const String chatDetail = '/chat-detail';

  // Pelacakan
  static const String deliveryTracker = '/tracker';
  static const String orderReview = '/order-review';

  // Lokasi Toko & Profile
  static const String storeLocation = '/store-location';
  static const String checkoutPayment = '/checkout-payment';
  static const String checkoutShipping = '/checkout-shipping';
  static const String checkoutCoupon = '/checkout-coupon';
  static const String editProfile = '/edit-profile';
  static const String myOrders = '/my-orders';
  static const String driverDashboard = '/driver-dashboard';

  // Admin
  static const String manageProducts = '/manage-products';
  static const String addEditProduct = '/add-edit-product';
  static const String manageCategories = '/manage-categories';
  static const String addEditCategory = '/add-edit-category';
  static const String manageBanners = '/manage-banners';
  static const String addEditBanner = '/add-edit-banner';
  static const String manageStores = '/manage-stores';
  static const String manageOrders = '/manage-orders';
  static const String addEditStore = '/add-edit-store';
  static const String manageTransactions = '/manage-transactions';
  static const String transactionDetail = '/transaction-detail';
  static const String manageCoupons = '/manage-coupons';
  static const String addEditCoupon = '/add-edit-coupon';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
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
        return MaterialPageRoute(builder: (_) => ProductDetailPage(product: args));
      case wishlist:
        return MaterialPageRoute(builder: (_) => const WishlistPage());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationPage());
      case messageList:
        return MaterialPageRoute(builder: (_) => const MessageListPage());

      // --- PERBAIKAN CHAT DETAIL ---
      case chatDetail:
        return MaterialPageRoute(
          settings: settings, // Sangat Penting: Agar ID Pesanan sampai ke halaman chat
          builder: (_) => const ChatDetailPage(),
        );

      case deliveryTracker:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const DeliveryTrackerPage(),
        );
      case orderReview:
        return MaterialPageRoute(builder: (_) => const OrderReviewPage());
      case storeLocation:
        return MaterialPageRoute(builder: (_) => const StoreLocationPage());
      case checkoutPayment:
        return MaterialPageRoute(builder: (_) => const CheckoutPaymentMethodPage());
      case checkoutShipping:
        return MaterialPageRoute(builder: (_) => const CheckoutShippingAddressPage());
      case checkoutCoupon:
        return MaterialPageRoute(builder: (_) => const CheckoutCouponApplyPage());
      case editProfile:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => EditProfilePage(
            initialName: args?['name'] ?? '',
            initialEmail: args?['email'] ?? '',
            initialPhotoUrl: args?['profilePhotoUrl'],
          ),
        );
      case manageProducts:
        return MaterialPageRoute(builder: (_) => const ManageProductsPage());
      case addEditProduct:
        final args = settings.arguments as Product?;
        return MaterialPageRoute(builder: (_) => AddEditProductPage(product: args));
      case manageCategories:
        return MaterialPageRoute(builder: (_) => const ManageCategoriesPage());
      case addEditCategory:
        final args = settings.arguments as Category?;
        return MaterialPageRoute(builder: (_) => AddEditCategoryPage(category: args));
      case manageBanners:
        return MaterialPageRoute(builder: (_) => const ManageBannersPage());
      case addEditBanner:
        final args = settings.arguments as BannerModel?;
        return MaterialPageRoute(builder: (_) => AddEditBannerPage(banner: args));
      case manageStores:
        return MaterialPageRoute(builder: (_) => const ManageStoresPage());
      case manageOrders:
        return MaterialPageRoute(builder: (_) => const ManageOrdersPage());
      case addEditStore:
        final args = settings.arguments as StoreModel?;
        return MaterialPageRoute(builder: (_) => AddEditStorePage(store: args));
      case manageTransactions:
        return MaterialPageRoute(builder: (_) => const ManageTransactionsPage());
      case transactionDetail:
        final args = settings.arguments as Order;
        return MaterialPageRoute(builder: (_) => TransactionDetailPage(order: args));
      case manageCoupons:
        return MaterialPageRoute(builder: (_) => const ManageCouponsPage());
      case addEditCoupon:
        return MaterialPageRoute(builder: (_) => const AddEditCouponPage());
      case myOrders:
        return MaterialPageRoute(builder: (_) => const MyOrdersPage());
      case driverDashboard:
        return MaterialPageRoute(builder: (_) => const DriverDashboardPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}