import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../core/routes/app_routes.dart';
import 'checkout_stepper.dart';

class CheckoutShippingAddressPage extends StatefulWidget {
  const CheckoutShippingAddressPage({Key? key}) : super(key: key);

  @override
  State<CheckoutShippingAddressPage> createState() =>
      _CheckoutShippingAddressPageState();
}

class _CheckoutShippingAddressPageState
    extends State<CheckoutShippingAddressPage> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController zipCtrl = TextEditingController();
  final TextEditingController countryCtrl = TextEditingController();
  final TextEditingController stateCtrl = TextEditingController();
  final TextEditingController cityCtrl = TextEditingController();
  final TextEditingController addressCtrl =
      TextEditingController(); // Added address field

  bool saveAddress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        nameCtrl.text = user.name;
      }
    });
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    zipCtrl.dispose();
    countryCtrl.dispose();
    stateCtrl.dispose();
    cityCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  void _onNext() {
    // Save address to provider
    final addressData = {
      'recipient_name': nameCtrl.text,
      'address_line': addressCtrl.text, // Added this field in UI
      'city': cityCtrl.text,
      'state': stateCtrl.text,
      'country': countryCtrl.text,
      'zip_code': zipCtrl.text,
    };

    Provider.of<OrderProvider>(context, listen: false)
        .setShippingAddress(addressData);

    // Navigate to Payment (Step 1)
    Navigator.pushNamed(context, AppRoutes.checkoutPayment);
  }

  Widget _roundedNextButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      child: SizedBox(
        height: 58,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF523946),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
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
              Icon(Icons.play_arrow, size: 22, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _labelledField(String label, TextEditingController ctrl,
      {String? hint, bool isDropdown = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          readOnly: isDropdown,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black87),
            suffixIcon: isDropdown ? const Icon(Icons.arrow_drop_down) : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide:
                  const BorderSide(color: Color(0xFF523946), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar putih bersih
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: CheckoutStepper(
          step: 0,
          onBack: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _labelledField('Recipient Name', nameCtrl),
                    _labelledField('Address', addressCtrl,
                        hint: 'Street address'),
                    _labelledField('Zip/postal Code', zipCtrl),
                    _labelledField('Country', countryCtrl,
                        hint: 'Choose your country',
                        isDropdown: false), // Simplified to text for now
                    _labelledField('State', stateCtrl, hint: 'Enter here'),
                    _labelledField('City', cityCtrl, hint: 'Enter here'),

                    const SizedBox(height: 6),

                    // ✅ Checkbox baris bawah
                    Row(
                      children: [
                        Checkbox(
                          activeColor: const Color(0xFF523946),
                          value: saveAddress,
                          onChanged: (v) =>
                              setState(() => saveAddress = v ?? false),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Save shipping address',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),

            // ✅ Tombol NEXT
            _roundedNextButton(),
          ],
        ),
      ),
    );
  }
}
