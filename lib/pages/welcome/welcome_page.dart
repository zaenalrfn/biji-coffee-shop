import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<String> welcomeImages = [
    "assets/images/welcome.png",
    "assets/images/welcome.png",
    "assets/images/welcome.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7EDEB),
      body: SafeArea(
        child: Column(
          children: [
            // === SLIDER IMAGE ===
            Expanded(
              flex: 7,
              child: PageView.builder(
                controller: _controller,
                itemCount: welcomeImages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.zero,
                    child: Image.asset(
                      welcomeImages[index],
                      fit: BoxFit.cover, // penuh layar kanan-kiri dan atas
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  );
                },
              ),
            ),

            // === DOTS INDICATOR ===
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  welcomeImages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: _currentPage == index ? 12 : 8,
                    height: _currentPage == index ? 12 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFF4B3B47)
                          : const Color(0xFFBCAEB6),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),

            // === BUTTONS ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                children: [
                  // LOGIN button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4B3B47),
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      child: const Text(
                        "LOGIN",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // SIGN UP button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF8CFAE),
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                      },
                      child: const Text(
                        "SIGN UP FOR FREE",
                        style: TextStyle(
                          color: Color(0xFF4B3B47),
                          fontSize: 16,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
