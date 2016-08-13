// lib/pages/checkout/checkout_stepper.dart
import 'package:flutter/material.dart';

class CheckoutStepper extends StatelessWidget implements PreferredSizeWidget {
  final int step; // 0: Shipping, 1: Payment, 2: Coupon
  final ValueChanged<int>? onStepTap;
  final VoidCallback? onBack;

  const CheckoutStepper({
    Key? key,
    required this.step,
    this.onStepTap,
    this.onBack,
  }) : super(key: key);

  static const _labels = ['Shipping Address', 'Coupon Apply', 'Payment Method'];

  @override
  Widget build(BuildContext context) {
    final leftLabel = step == 0
        ? '' // Jika step 0, kiri kosong
        : _labels[step - 1];

    final rightLabel = step == _labels.length - 1
        ? '' // Jika step terakhir, kanan kosong
        : _labels[step + 1];

    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔹 App bar row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Row(
              children: [
                InkWell(
                  onTap: onBack ?? () => Navigator.of(context).maybePop(),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_back, size: 26),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Checkout',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // 🔹 Label kiri - tengah - kanan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Kiri (abu, klik ke step sebelumnya)
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        if (step > 0) {
                          onStepTap?.call(step - 1);
                        }
                      },
                      child: Text(
                        leftLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),

                // Tengah (aktif)
                Expanded(
                  child: Center(
                    child: Text(
                      _labels[step],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3E2B47),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                // Kanan (abu, klik ke step selanjutnya)
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        if (step < _labels.length - 1) {
                          onStepTap?.call(step + 1);
                        }
                      },
                      child: Text(
                        rightLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade400,
                        ),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 🔹 Garis + lingkaran
          SizedBox(
            height: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ======================================================
                // === REVISI DI SINI ===
                //
                // Garis lurus tunggal yang pas selebar layar
                Container(
                  height: 2, // Tinggi garis
                  width: double.infinity, // Lebar penuh "pas layar"
                  color: Colors.grey.shade300,
                ),
                //
                // ======================================================

                // Lingkaran tengah (tetap sama)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFF523946),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(140);
}
