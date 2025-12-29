import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../core/routes/app_routes.dart';
import 'checkout_stepper.dart';

class CheckoutPaymentMethodPage extends StatefulWidget {
  const CheckoutPaymentMethodPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPaymentMethodPage> createState() =>
      _CheckoutPaymentMethodPageState();
}

class _CheckoutPaymentMethodPageState extends State<CheckoutPaymentMethodPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set default payment method automatically as only Midtrans is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false)
          .setPaymentMethod('midtrans');
    });
  }

  void _onPlaceOrder() async {
    setState(() => _isLoading = true);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    try {
      final snapToken = await orderProvider.createOrder();

      // Clear cart
      cartProvider.clearCartLocal();
      await cartProvider.fetchCart();

      if (mounted) {
        if (snapToken != null) {
          // Open Midtrans Snap URL
          // Construct URL: https://app.sandbox.midtrans.com/snap/v2/vtweb/{snap_token}
          final url = Uri.parse(
              'https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken');

          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Order created. Redirecting to payment...')),
            );
            // Navigate to Tracker/Home
            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.deliveryTracker, (route) => route.isFirst);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not launch payment page.')),
            );
          }
        } else {
          // Success without payment link (?)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order placed successfully!')),
          );
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.deliveryTracker, (route) => route.isFirst);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _roundedPlaceOrderButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF523946),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: _isLoading ? null : _onPlaceOrder,
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'PLACE ORDER',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.check_circle, size: 22, color: Colors.white),
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
          step: 2,
          onBack: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Method',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ]),
                      child: Row(
                        children: [
                          // Simple Icon or Text for Midtrans
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12)),
                            child:
                                const Icon(Icons.payment, color: Colors.blue),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Midtrans Payment Gateway',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                SizedBox(height: 4),
                                Text(
                                    'Supports GoPay, OVO, ShopeePay, Bank Transfer, Card',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          const Icon(Icons.check_circle,
                              color: Color(0xFF523946))
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                        'You will be redirected to the secure payment page after clicking "Place Order".',
                        style: TextStyle(color: Colors.grey, height: 1.5)),

                    const SizedBox(height: 40),
                    const Divider(),
                    const SizedBox(height: 16),

                    // TOTAL PAYMENT
                    Consumer<CartProvider>(builder: (context, cart, _) {
                      return Row(
                        children: [
                          Text('Total Payment',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 16)),
                          const Spacer(),
                          Text('\$${cart.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF523946))),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
            _roundedPlaceOrderButton(),
          ],
        ),
      ),
    );
  }
}
