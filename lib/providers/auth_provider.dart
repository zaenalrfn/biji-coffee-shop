import 'dart:io';
import 'dart:convert';
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
    // 1. Try to load user from local cache first (OFFLINE SUPPORT)
    _user = await _loadUserLocally();
    notifyListeners();

    final token = await _apiService.getToken();
    if (token != null) {
      try {
        // 2. Refresh from API
        final onlineUser = await _apiService.getUser();
        _user = onlineUser;
        // 3. Update local cache
        await _saveUserLocally(onlineUser);
      } catch (e) {
        debugPrint('CheckLoginStatus error: $e');
        // Only logout if explicitly unauthenticated (401)
        // Adjust string check based on your specific 401 exception message
        if (e.toString().contains('Unauthenticated') ||
            e.toString().contains('401')) {
          await logout();
        } else {
          // If network error, we stay logged in with cached user
          // If no cached user, we might be in trouble, but let's hope for cache.
          if (_user == null) {
            await logout(); // No cache + No API = Logout
          }
        }
      }
      notifyListeners();
    } else {
      // No token? Clear everything
      await logout();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      final token = response['access_token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);

      if (response.containsKey('user')) {
        _user = User.fromJson(response['user']);
        // Save to cache
        await _saveUserLocally(_user!);
      } else {
        final fetchedUser = await _apiService.getUser();
        _user = fetchedUser;
        await _saveUserLocally(fetchedUser);
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

  Future<bool> loginGuest() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.loginGuest();
      // Assuming response has 'access_token' similar to login
      if (response.containsKey('access_token')) {
        final token = response['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);

        // Try to get user data from response or fetch it
        // If it's a guest, maybe backend returns a specific structure or we fetch /user which returns guest info
        // For robustness, let's assume we fetch /user or fallback
        try {
          if (response.containsKey('user')) {
            _user = User.fromJson(response['user']);
          } else {
            _user = await _apiService.getUser();
          }
        } catch (e) {
          // If fetching user fails (maybe guest endpoint doesn't return full user), use dummy
          _user = User(
              id: 0,
              name: 'Guest',
              email: 'guest@biji.coffee',
              roles: ['guest']);
        }

        if (_user != null) {
          await _saveUserLocally(_user!);
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      _errorMessage = 'No access token';
      notifyListeners();
      return false;
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

      if (response.containsKey('access_token')) {
        final token = response['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);

        final fetchedUser = await _apiService.getUser();
        _user = fetchedUser;
        await _saveUserLocally(fetchedUser);
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

  Future<bool> updateProfile(String name, String email, File? imageFile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call API to update profile
      final updatedUser =
          await _apiService.updateProfile(name, email, imageFile);

      // Update local user state
      _user = updatedUser;
      await _saveUserLocally(updatedUser);

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
      debugPrint("Logout error: $e");
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_data'); // Clear cache

    _user = null;
    notifyListeners();
  }

  // 💾 Cache Helpers
  Future<void> _saveUserLocally(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint("Failed to save user locally: $e");
    }
  }

  Future<User?> _loadUserLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      if (userData != null) {
        return User.fromJson(jsonDecode(userData));
      }
    } catch (e) {
      debugPrint("Failed to load user locally: $e");
    }
    return null;
  }
}
