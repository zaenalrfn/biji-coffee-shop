import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // 1. GANTI IP LAPTOP DISINI (Jadikan Default)
  static const String serverIp = '192.168.18.7'; // Update sesuai request user

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    } else {
      try {
        // Prioritas: .env -> Code diatas
        final ip = dotenv.env['SERVER_IP'] ?? serverIp; 
        return 'http://$ip:8000/api';
      } catch (e) {
        return 'http://$serverIp:8000/api';
      }
    }
  }

  static String get loginEndpoint => '$baseUrl/login';
  static String get registerEndpoint => '$baseUrl/register';
  static String get userEndpoint => '$baseUrl/user';
}
