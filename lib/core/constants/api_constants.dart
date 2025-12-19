class ApiConstants {
  // Ganti dengan IP lokal laptop jika pakai device fisik, misal 192.168.1.x
  // Gunakan 10.0.2.2 untuk Emulator Android, 127.0.0.1 untuk Emulator iOS / Web / Desktop
  static const String baseUrl = 'http://192.168.1.33:8000/api';

  static const String loginEndpoint = '$baseUrl/login';
  static const String registerEndpoint = '$baseUrl/register';
  static const String userEndpoint = '$baseUrl/user';
}
