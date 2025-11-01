import 'package:flutter/material.dart';
import '../../pages/onboarding/onboarding_page.dart';
import '../../pages/welcome/welcome_page.dart';
import '../../pages/auth/login_page.dart';
import '../../pages/home/home_page.dart';
import '../../pages/cart/cart_page.dart';
import '../../pages/rewards/rewards_page.dart';
import '../../pages/profile/profile_page.dart';
import '../../pages/products/products_page.dart'; // tambahkan ini karena ada route /products

class AppRoutes {
  // Daftar route name
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String cart = '/cart';
  static const String rewards = '/rewards';
  static const String profile = '/profile';
  static const String products = '/products'; // dari branch Zaenal

  // Generator route
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      // case register:
      //   return MaterialPageRoute(builder: (_) => const RegisterPage());
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
}
