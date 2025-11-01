import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final lastRoute = prefs.getString('last_route') ?? AppRoutes.onboarding;
  runApp(CoffeeShopApp(initialRoute: lastRoute));
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
        // Simpan route setiap kali generate route (kecuali onboarding)
        if (settings.name != null && settings.name != AppRoutes.onboarding && settings.name != '/') {
          _saveRoute(settings.name!);
        }
        return AppRoutes.generateRoute(settings);
      },
      initialRoute: initialRoute,
      debugShowCheckedModeBanner: false,
    );
  }

  Future<void> _saveRoute(String routeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_route', routeName);
  }
}
