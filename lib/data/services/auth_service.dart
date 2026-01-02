import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  // Key for storing the token
  static const String _tokenKey = 'auth_token';

  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Save the authentication token securely
  /// NOTE: We also save to SharedPreferences because existing ApiService and AuthProvider
  /// rely on SharedPreferences.
  Future<void> saveToken(String token) async {
    // 1. Save to Secure Storage (Friend's logic)
    await _storage.write(key: _tokenKey, value: token);

    // 2. Save to SharedPreferences (Legacy compatibility)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  /// Retrieve the authentication token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Delete the authentication token (logout)
  Future<void> deleteToken() async {
    // 1. Delete from Secure Storage
    await _storage.delete(key: _tokenKey);

    // 2. Delete from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  /// Check if user is authenticated
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null;
  }
}
