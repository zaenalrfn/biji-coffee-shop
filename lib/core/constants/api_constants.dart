import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl {
    if (!dotenv.isInitialized) {
      return 'https://d6b0081930fe.ngrok-free.app/api';
    }
    return dotenv.env['API_BASE_URL'] ??
        'https://d6b0081930fe.ngrok-free.app/api';
  }

  static String get loginEndpoint => '$baseUrl/login';
  static String get registerEndpoint => '$baseUrl/register';
  static String get userEndpoint => '$baseUrl/user';
  static String get googleAuthEndpoint => '$baseUrl/oauth/google';
  static String get serverIp {
    try {
      return Uri.parse(baseUrl).host;
    } catch (e) {
      return 'localhost';
    }
  }
}
