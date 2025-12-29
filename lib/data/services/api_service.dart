import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/banner_model.dart';
import '../models/store_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/driver_model.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/api_constants.dart';
import 'auth_service.dart';

class ApiService {
  final AuthService _authService = AuthService();

  Future<String?> getToken() async {
    return await _authService.getToken();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ================= AUTH =================

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.loginEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.registerEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  Future<void> logout() async {
    final headers = await _getHeaders();
    await http.post(
      Uri.parse('${ApiConstants.baseUrl}/logout'),
      headers: headers,
    );
  }

  Future<User> getUser() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(ApiConstants.userEndpoint),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get user');
    }
  }

  // ================= ORDERS =================

  Future<List<Order>> getOrders() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/orders'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list =
          (data is Map && data.containsKey('data')) ? data['data'] : data;
      return list.map((e) => Order.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<Order> getOrderById(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/orders/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final orderData =
          (data is Map && data.containsKey('data')) ? data['data'] : data;
      return Order.fromJson(orderData);
    } else {
      throw Exception('Failed to load order detail');
    }
  }

  // ================= ORDER MESSAGES =================

  Future<List<dynamic>> getMessages(int orderId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/orders/$orderId/messages'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memuat pesan');
    }
  }

  Future<void> sendMessage(int orderId, String message) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/orders/$orderId/messages'),
      headers: headers,
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal mengirim pesan');
    }
  }

  // ================= DRIVER =================

  Future<List<Driver>> getDrivers() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/drivers'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List data =
          (json is Map && json.containsKey('data')) ? json['data'] : json;
      return data.map((e) => Driver.fromJson(e)).toList();
    } else {
      throw Exception('Failed to get drivers');
    }
  }

  Future<List<Order>> getDriverOrders() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/driver/orders'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List data =
          (json is Map && json.containsKey('data')) ? json['data'] : json;
      return data.map((e) => Order.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load driver orders');
    }
  }

  Future<void> updateDriverOrderStatus(int orderId, String status) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/driver/orders/$orderId/status'),
      headers: headers,
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update status');
    }
  }

  Future<void> assignDriver(int orderId, int driverId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/admin/orders/$orderId/assign-driver'),
      headers: headers,
      body: jsonEncode({'driver_id': driverId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to assign driver');
    }
  }
}
