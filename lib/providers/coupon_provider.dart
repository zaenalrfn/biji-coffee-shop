import 'package:flutter/material.dart';
import '../data/models/coupon_model.dart';
import '../data/services/api_service.dart';

class CouponProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // _coupons removed to fix lint
  // Ideally use Coupon Model, but getAdminCoupons returns List<dynamic> currently in ApiService.
  // I will assume ApiService returns List<dynamic> (Maps) and I will parse them here or in ApiService.
  // Actually, I should update ApiService to return List<Coupon>.
  // But let's check ApiService again. It returns List<dynamic>.
  // I'll parse them to Coupon models here.

  List<Coupon> _couponModels = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Coupon> get coupons => _couponModels;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCoupons() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.getAdminCoupons();
      _couponModels = data.map((json) => Coupon.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = e.toString();
      _couponModels = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCoupon(Coupon coupon) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.createCoupon(coupon.toJson());
      await fetchCoupons();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> deleteCoupon(int id) ... need to add deleteCoupon to ApiService if not exists?
  // I checked ApiService previously, I didn't add deleteCoupon. I only added deleteOrder.
  // I need to add deleteCoupon to ApiService first or now.
  // Wait, I saw "Admin - Delete Coupon" in Postman.

  Future<void> deleteCoupon(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.deleteCoupon(id);
      _couponModels.removeWhere((c) => c.id == id);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
