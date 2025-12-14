import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/routes/app_routes.dart';
import 'checkout_stepper.dart';

enum PaymentMethod { creditCard, bankTransfer, virtualAccount }

class CheckoutPaymentMethodPage extends StatefulWidget {
  const CheckoutPaymentMethodPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPaymentMethodPage> createState() =>
      _CheckoutPaymentMethodPageState();
}

class _CheckoutPaymentMethodPageState extends State<CheckoutPaymentMethodPage> {
  PaymentMethod? _selected = PaymentMethod.creditCard;

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _cardNumberCtrl =
      TextEditingController(text: '1234 5678 9101 1121');
  final TextEditingController _monthYearCtrl = TextEditingController();
  final TextEditingController _cvvCtrl = TextEditingController();
  final TextEditingController _countryCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        _nameCtrl.text = user.name;
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cardNumberCtrl.dispose();
    _monthYearCtrl.dispose();
    _cvvCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  void _onNext() {
    // Save payment method
    String method = 'Credit Card';
    if (_selected == PaymentMethod.bankTransfer) method = 'Bank Transfer';
    if (_selected == PaymentMethod.virtualAccount) method = 'Virtual Account';

    Provider.of<OrderProvider>(context, listen: false).setPaymentMethod(method);

    // Navigate to Coupon (Step 2)
    Navigator.pushNamed(context, AppRoutes.checkoutCoupon);
  }

  // reusable text field
  Widget _textField(String label, TextEditingController ctrl, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint ?? '',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF523946), width: 1),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _creditCardExpanded() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // horizontal sliding mock cards
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            children: [
              Container(
                width: 300,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8A3FFC), Color(0xFF523946)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3))
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Credit Card',
                        style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const Spacer(),
                    Text(
                      _cardNumberCtrl.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('04 / 25',
                            style: TextStyle(color: Colors.white70)),
                        Text(
                          _nameCtrl.text.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _textField('Card Holder Name', _nameCtrl),
        _textField('Card Number', _cardNumberCtrl),
        Row(
          children: [
            Expanded(
                child: _textField('Month/Year', _monthYearCtrl, hint: 'MM/YY')),
            const SizedBox(width: 12),
            Expanded(child: _textField('CVV', _cvvCtrl, hint: '123')),
          ],
        ),
        _textField('Country', _countryCtrl, hint: 'Choose your country'),
      ],
    );
  }

  Widget _bankTransferExpanded() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _textField('Account Name', _nameCtrl),
        _textField('Bank Name', _cardNumberCtrl, hint: 'Enter your bank'),
        _textField('Account Number', _monthYearCtrl,
            hint: 'Enter account number'),
      ],
    );
  }

  Widget _virtualAccountExpanded() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _textField('Virtual Account Name', _nameCtrl),
        _textField('Virtual Account Number', _cardNumberCtrl),
        _textField('Bank', _countryCtrl, hint: 'Choose your bank'),
      ],
    );
  }

  Widget _roundedNextButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: SizedBox(
        height: 58,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF523946),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
          ),
          onPressed: _onNext,
          child: Row(
            children: const [
              SizedBox(width: 8),
              Text(
                'NEXT',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16),
              ),
              Spacer(),
              Icon(Icons.play_arrow, color: Colors.white, size: 22),
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
          step: 1,
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
                    // CREDIT CARD OPTION
                    Row(
                      children: [
                        Radio<PaymentMethod>(
                          value: PaymentMethod.creditCard,
                          groupValue: _selected,
                          onChanged: (v) => setState(() => _selected = v),
                          activeColor: const Color(0xFF523946),
                        ),
                        const Text('Credit Card',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    if (_selected == PaymentMethod.creditCard)
                      _creditCardExpanded(),
                    const Divider(),

                    // BANK TRANSFER OPTION
                    Row(
                      children: [
                        Radio<PaymentMethod>(
                          value: PaymentMethod.bankTransfer,
                          groupValue: _selected,
                          onChanged: (v) => setState(() => _selected = v),
                          activeColor: const Color(0xFF523946),
                        ),
                        const Text('Bank Transfer',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    if (_selected == PaymentMethod.bankTransfer)
                      _bankTransferExpanded(),
                    const Divider(),

                    // VIRTUAL ACCOUNT OPTION
                    Row(
                      children: [
                        Radio<PaymentMethod>(
                          value: PaymentMethod.virtualAccount,
                          groupValue: _selected,
                          onChanged: (v) => setState(() => _selected = v),
                          activeColor: const Color(0xFF523946),
                        ),
                        const Text('Virtual Account',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    if (_selected == PaymentMethod.virtualAccount)
                      _virtualAccountExpanded(),

                    const SizedBox(height: 30),

                    // TOTAL PAYMENT
                    Consumer<CartProvider>(builder: (context, cart, _) {
                      return Row(
                        children: [
                          Text('Total Payment',
                              style: TextStyle(color: Colors.grey.shade600)),
                          const Spacer(),
                          Text('\$${cart.totalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.w800)),
                        ],
                      );
                    }),
                    const SizedBox(height: 40),
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
