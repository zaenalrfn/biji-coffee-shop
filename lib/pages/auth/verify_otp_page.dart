import 'package:flutter/material.dart';

import 'reset_new_password_page.dart';

class VerifyOtpPage extends StatefulWidget {
  final String email;
  const VerifyOtpPage({Key? key, required this.email}) : super(key: key);

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final TextEditingController _otpCtrl = TextEditingController();

  void _onVerify() {
    final otp = _otpCtrl.text.trim();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid OTP')));
      return;
    }

    // Since API doesn't have verify-only endpoint, we just pass OTP to next page
    // assuming it's correct format. Validation happens at final reset.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResetNewPasswordPage(
          email: widget.email,
          otp: otp,
        ),
      ),
    );
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
              "Verify OTP 🔐",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B2A33),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Enter the OTP sent to ${widget.email}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "OTP Code",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _onVerify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B2A33),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Verify",
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
