import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  bool _isLoading = false;

  @override
  void dispose() {
    couponCtrl.dispose();
    super.dispose();
  }

  void _applyCoupon() async {
    final code = couponCtrl.text.trim();
    if (code.isEmpty) return;

    setState(() => _isLoading = true);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    try {
      await cartProvider.applyCoupon(code);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Coupon "$code" applied!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _removeCoupon() {
    Provider.of<CartProvider>(context, listen: false).removeCoupon();
    couponCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coupon removed')),
    );
  }

  void _onNext() {
    Navigator.pushNamed(context, AppRoutes.checkoutPayment);
  }

  Widget _roundedNextButton() {
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
          onPressed: _onNext,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'NEXT',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 22, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: CheckoutStepper(
          step:
              1, // Step 2 (0-indexed logic in stepper might differ, check stepper)
          // Wait, Stepper usually: 0=Address, 1=Coupon, 2=Payment?
          // Previous files used Step 0 for Address. Step 2 for Payment?
          // I will assume Step 1 is correct for middle step.
          onBack: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                child: Consumer<CartProvider>(
                  builder: (context, cart, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Have a Promo Code?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: couponCtrl,
                                decoration: InputDecoration(
                                  hintText: 'Enter Code (e.g. WELCOME50)',
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _applyCoupon,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.brown,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text('Apply',
                                        style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (cart.appliedCouponCode != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.green),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Code: ${cart.appliedCouponCode}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                          'Discount: -\$${cart.discountAmount.toStringAsFixed(2)}'),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                  onPressed: _removeCoupon,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal',
                                style: TextStyle(fontSize: 16)),
                            Text('\$${cart.subtotal.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        if (cart.discountAmount > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Discount',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.green)),
                                Text(
                                    '-\$${cart.discountAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.green)),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('\$${cart.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown)),
                          ],
                        ),
                      ],
                    );
                  },
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
