import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/store_model.dart';
import '../data/services/api_service.dart';

class StoreProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<StoreModel> _stores = [];
  bool _isLoading = false;

  List<StoreModel> get stores => _stores;
  bool get isLoading => _isLoading;

  Future<void> fetchStores() async {
    _isLoading = true;
    notifyListeners();
    try {
      _stores = await _apiService.getStores();
      notifyListeners();
    } catch (e) {
      print('Error fetching stores: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addStore({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required String openTime,
    required String closeTime,
    File? imageFile,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newStore = await _apiService.createStore(
        name: name,
        address: address,
        latitude: latitude,
        longitude: longitude,
        openTime: openTime,
        closeTime: closeTime,
        imageFile: imageFile,
      );
      _stores.add(newStore);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateStore({
    required int id,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required String openTime,
    required String closeTime,
    File? imageFile,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updatedStore = await _apiService.updateStore(
        id: id,
        name: name,
        address: address,
        latitude: latitude,
        longitude: longitude,
        openTime: openTime,
        closeTime: closeTime,
        imageFile: imageFile,
      );
      final index = _stores.indexWhere((s) => s.id == id);
      if (index != -1) {
        _stores[index] = updatedStore;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteStore(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.deleteStore(id);
      _stores.removeWhere((s) => s.id == id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
