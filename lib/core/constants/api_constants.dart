class ApiConstants {
  static String get baseUrl {
    return dotenv.env['API_BASE_URL'] ??
        'https://apibijicoffee.putrakembar.my.id/api';
  }

  static String get loginEndpoint => '$baseUrl/login';
  static String get registerEndpoint => '$baseUrl/register';
  static String get userEndpoint => '$baseUrl/user';
  static String get googleAuthEndpoint => '$baseUrl/oauth/google';
}
