import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Ganti dengan IP lokal laptop jika pakai device fisik, misal 192.168.1.x
  // Gunakan 10.0.2.2 untuk Emulator Android, 127.0.0.1 untuk Emulator iOS / Web / Desktop
  static String get baseUrl => dotenv.get('API_BASE_URL');

  static String get loginEndpoint => '$baseUrl/login';
  static String get registerEndpoint => '$baseUrl/register';
  static String get userEndpoint => '$baseUrl/user';
}
