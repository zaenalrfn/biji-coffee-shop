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

// Halaman notifikasi
import '../../pages/notification/notification_page.dart';

// Halaman pesan & chat
import '../../pages/messages/message_list_page.dart';
import '../../pages/messages/chat_detail_page.dart';


// Halaman pelacakan pesanan
import '../../pages/tracker/delivery_tracker_page.dart';

// Halaman lokasi toko
import '../../pages/store_location/store_location_page.dart';

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

  // Pesan & Chat
  static const String messageList = '/messages';
  static const String chatDetail = '/chat-detail';

  // Pelacakan
  static const String deliveryTracker = '/tracker';

  // Lokasi Toko
  static const String storeLocation = '/store-location';
  

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

      // ===== Lokasi Toko =====
      case storeLocation:
        return MaterialPageRoute(builder: (_) => const StoreLocationPage());

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