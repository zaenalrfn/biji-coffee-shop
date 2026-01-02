import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../models/notification_model.dart';

import '../services/auth_service.dart';

class NotificationService {
  Future<String?> _getToken() async {
    return await AuthService().getToken();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<NotificationItem>> getNotifications({int page = 1}) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/notifications?page=$page'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      // Handle Laravel's simplePaginate response structure
      // It usually returns { "data": [...], "current_page": 1, ... }
      // If it returns a list directly, handle that too (fallback)
      final List<dynamic> data =
          jsonResponse is Map && jsonResponse.containsKey('data')
              ? jsonResponse['data']
              : jsonResponse;

      return data.map((json) => NotificationItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notifications: ${response.body}');
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/notifications/$notificationId/read'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read: ${response.body}');
    }
  }

  Future<void> markAllRead() async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/notifications/read-all'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark all as read: ${response.body}');
    }
  }

  Future<void> deleteAll() async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/notifications/delete-all'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete all notifications: ${response.body}');
    }
  }
}
