import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Ganti dengan IP lokal laptop jika pakai device fisik, misal 192.168.1.x
  // Gunakan 10.0.2.2 untuk Emulator Android, 127.0.0.1 untuk Emulator iOS / Web / Desktop
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    } else {
      try {
        return dotenv.env['API_BASE_URL'] ?? 'http://192.168.100.49:8000/api';
      } catch (e) {
        // dotenv not initialized
        return 'http://192.168.100.49:8000/api';
      }
    }
  }

  static String get loginEndpoint => '$baseUrl/login';
  static String get registerEndpoint => '$baseUrl/register';
  static String get userEndpoint => '$baseUrl/user';
}
