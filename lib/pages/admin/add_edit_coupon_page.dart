import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/coupon_provider.dart';
import '../../data/models/coupon_model.dart';
import 'package:intl/intl.dart';

class AddEditCouponPage extends StatefulWidget {
  final Coupon?
      coupon; // If null, Add mode. If exists, Edit (Not implemented fully yet)

  const AddEditCouponPage({super.key, this.coupon});

  @override
  State<AddEditCouponPage> createState() => _AddEditCouponPageState();
}

class _AddEditCouponPageState extends State<AddEditCouponPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _minPurchaseCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  String _selectedType = 'percent'; // percent or fixed
  bool _isLoading = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _valueCtrl.dispose();
    _minPurchaseCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _saveCoupon() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final coupon = Coupon(
      code: _codeCtrl.text.trim(),
      type: _selectedType,
      value: double.parse(_valueCtrl.text),
      minPurchase: double.parse(_minPurchaseCtrl.text),
      expiresAt: _dateCtrl.text.isNotEmpty ? _dateCtrl.text : null,
      isActive: true,
    );

    try {
      await Provider.of<CouponProvider>(context, listen: false)
          .addCoupon(coupon);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kupon berhasil dibuat')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Gagal: ${e.toString().replaceAll('Exception:', '')}')),
        );
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
        title: const Text('Buat Kupon Baru'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _codeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Kode Kupon',
                  border: OutlineInputBorder(),
                  hintText: 'CONTOH: PROMO50',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipe Diskon',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'percent', child: Text('Persentase (%)')),
                  DropdownMenuItem(
                      value: 'fixed', child: Text('Nominal Tetap (Rp)')),
                ],
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valueCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _selectedType == 'percent'
                      ? 'Besar Diskon (%)'
                      : 'Besar Diskon (Rp)',
                  border: const OutlineInputBorder(),
                  suffixText: _selectedType == 'percent' ? '%' : 'IDR',
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _minPurchaseCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Minimal Belanja (Rp)',
                  border: OutlineInputBorder(),
                  hintText: '0 jika tanpa minimum',
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateCtrl,
                readOnly: true,
                onTap: _selectDate,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Kadaluarsa (Opsional)',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF523946),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _saveCoupon,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SIMPAN KUPON',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
