import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/cart_provider.dart';
import '../../core/routes/app_routes.dart';
import 'checkout_stepper.dart';

class CheckoutCouponApplyPage extends StatefulWidget {
  const CheckoutCouponApplyPage({Key? key}) : super(key: key);

  @override
  State<CheckoutCouponApplyPage> createState() =>
      _CheckoutCouponApplyPageState();
}

class _CheckoutCouponApplyPageState extends State<CheckoutCouponApplyPage> {
  final TextEditingController couponCtrl = TextEditingController();
  bool applyCoupon = false;
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    // Prevent accidental double-tap from previous page
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _canSubmit = true);
    });
  }

  @override
  void dispose() {
    couponCtrl.dispose();
    super.dispose();
  }

  void _onPlaceOrder() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    try {
      await orderProvider.createOrder();

      // Clear cart
      await cartProvider.fetchCart(); // Or implement clearCart() method

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.deliveryTracker, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        // Clean up error message
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _roundedNextButton() {
    final isLoading = context.watch<OrderProvider>().isLoading;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF523946),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          onPressed: (isLoading || !_canSubmit) ? null : _onPlaceOrder,
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Row(
                  children: [
                    const SizedBox(width: 12),
                    const Text(
                      'PLACE ORDER',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.check_circle,
                        size: 22, color: Colors.white),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _labelledField(String label, TextEditingController ctrl,
      {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: const BorderSide(color: Color(0xFF523946), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: CheckoutStepper(
          step: 2,
          onBack: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _labelledField('Enter Coupon Code', couponCtrl,
                        hint: 'Promo Code'),
                    Row(
                      children: [
                        Checkbox(
                          value: applyCoupon,
                          onChanged: (v) =>
                              setState(() => applyCoupon = v ?? false),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Apply coupon automatically',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Consumer<CartProvider>(
                      builder: (context, cart, _) => Text(
                        "Total: \$${cart.totalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
            _roundedNextButton(),
          ],
        ),
      ),
    );
  }
}
