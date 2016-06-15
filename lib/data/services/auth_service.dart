import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }
}
