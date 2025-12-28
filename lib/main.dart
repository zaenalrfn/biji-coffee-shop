import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';

import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/banner_provider.dart';
import 'providers/store_provider.dart';
import 'data/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Failed to load .env file: $e");
  }
  // Check URL for token (Web Redirect Flow)
  String? urlToken = Uri.base.queryParameters['token'];
  if (urlToken != null) {
    debugPrint("Found token in URL: $urlToken");
    await AuthService().saveToken(urlToken);
    // Optional: Clean URL? Hard to do without reloading.
    // For now, simple redirect flow.
  }

  final prefs = await SharedPreferences.getInstance();

  // Check if user is logged in & seen onboarding
  // We check AuthService first as it might have just been updated from URL
  String? token =
      await AuthService().getToken(); // Check consistent secure storage/url
  if (token == null) {
    // Fallback to legacy prefs if migration isn't 100% complete or for safety
    token = prefs.getString('access_token');
  }

  final bool seenOnboarding = prefs.getBool('seen_onboarding') ?? false;

  String initialRoute;
  if (token != null) {
    initialRoute = AppRoutes.home;
  } else if (!seenOnboarding) {
    initialRoute = AppRoutes.onboarding;
  } else {
    initialRoute = AppRoutes.welcome;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthProvider()..checkLoginStatus()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => BannerProvider()),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
      ],
      child: CoffeeShopApp(initialRoute: initialRoute),
    ),
  );
}

class CoffeeShopApp extends StatelessWidget {
  final String initialRoute;
  const CoffeeShopApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Shop App',
      theme: AppTheme.light,
      onGenerateRoute: (settings) {
        // Logic save route bisa diaktifkan kembali jika needed, tapi hati-hati dengan auth flow
        /*
        if (settings.name != null &&
            settings.name != AppRoutes.onboarding &&
            settings.name != '/') {
          _saveRoute(settings.name!);
        }
        */
        return AppRoutes.generateRoute(settings);
      },
      initialRoute: initialRoute,
      debugShowCheckedModeBanner: false,
    );
  }

  // Future<void> _saveRoute(String routeName) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('last_route', routeName);
  // }
}
