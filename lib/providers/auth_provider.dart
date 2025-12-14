import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/services/api_service.dart';
import '../data/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<void> checkLoginStatus() async {
    final token = await _apiService.getToken();
    if (token != null) {
      try {
        _user = await _apiService.getUser();
      } catch (e) {
        // Token might be invalid
        await logout();
      }
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      final token = response['access_token']; // Adjust based on API response
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);

      // Fetch user details
      _user = await _apiService.getUser();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.register(name, email, password);
      // Assuming register returns token, if not, user needs to login
      if (response.containsKey('access_token')) {
        final token = response['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        _user = await _apiService.getUser();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // Ignore errors on logout
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    _user = null;
    notifyListeners();
  }
}
