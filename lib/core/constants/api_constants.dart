import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // 1. GANTI IP LAPTOP DISINI (Jadikan Default)
  static const String serverIp = '192.168.18.7'; // Update sesuai request user

  static String get baseUrl {
    if (kIsWeb) {
      return 'https://e1f950e671d2.ngrok-free.app/api';
    } else {
      try {
        return dotenv.env['API_BASE_URL'] ??
            'https://e1f950e671d2.ngrok-free.app/api';
      } catch (e) {
        // dotenv not initialized
        return 'https://e1f950e671d2.ngrok-free.app/api';
      }
    }
  }

  static String get loginEndpoint => '$baseUrl/login';
  static String get registerEndpoint => '$baseUrl/register';
  static String get userEndpoint => '$baseUrl/user';
}
