import 'package:flutter/material.dart';
import '../../data/services/api_service.dart';
import '../../core/routes/app_routes.dart';

class ResetNewPasswordPage extends StatefulWidget {
  final String email;
  final String otp;
  const ResetNewPasswordPage({Key? key, required this.email, required this.otp})
      : super(key: key);

  @override
  State<ResetNewPasswordPage> createState() => _ResetNewPasswordPageState();
}

class _ResetNewPasswordPageState extends State<ResetNewPasswordPage> {
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _onReset() async {
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (pass.isEmpty || pass.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Password must be at least 8 characters')));
      return;
    }
    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _apiService.resetPassword(widget.email, widget.otp, pass);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Password reset successfully! Please login.')));

        // Go back to Login (remove all history)
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.login, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "New Password 🔒",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B2A33),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Create a new strong password for your account.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.check_circle_outline),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B2A33),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Reset Password",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
