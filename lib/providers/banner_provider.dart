import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/banner_model.dart';
import '../data/services/api_service.dart';

class BannerProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<BannerModel> _banners = [];
  bool _isLoading = false;

  List<BannerModel> get banners => _banners;
  bool get isLoading => _isLoading;

  Future<void> fetchBanners() async {
    _isLoading = true;
    notifyListeners();

    try {
      _banners = await _apiService.getBanners();
    } catch (e) {
      print('Error fetching banners: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBanner(String name,
      {File? imageFile, String? imageUrl}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newBanner = await _apiService.createBanner(
        name: name,
        imageFile: imageFile,
        imageUrl: imageUrl,
      );
      _banners.add(newBanner);
      notifyListeners();
    } catch (e) {
      print('Error adding banner: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBanner(int id, String name,
      {File? imageFile, String? imageUrl}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedBanner = await _apiService.updateBanner(
        id: id,
        name: name,
        imageFile: imageFile,
        imageUrl: imageUrl,
      );
      final index = _banners.indexWhere((b) => b.id == id);
      if (index != -1) {
        _banners[index] = updatedBanner;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating banner: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBanner(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.deleteBanner(id);
      _banners.removeWhere((b) => b.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting banner: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
