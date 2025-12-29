import 'package:flutter/material.dart';
import '../data/services/api_service.dart';

class PointProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  int _points = 0;
  bool _isLoading = false;
  String? _errorMessage;

  int get points => _points;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPoints() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _points = await _apiService.getUserPoints();
    } catch (e) {
      _errorMessage = e.toString();
      print('Error fetching points: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
