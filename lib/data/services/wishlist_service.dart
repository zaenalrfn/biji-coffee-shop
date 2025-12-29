import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../models/wishlist_item_model.dart';

import '../services/auth_service.dart';

class WishlistService {
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

  Future<List<WishlistItem>> getWishlist() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/wishlist'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => WishlistItem.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load wishlist');
    }
  }

  Future<bool> addToWishlist(int productId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/wishlist'),
      headers: headers,
      body: jsonEncode({'product_id': productId}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 409) {
      // Already in wishlist
      return false; // or throw specific exception if UI needs to know
    } else {
      throw Exception('Failed to add to wishlist: ${response.body}');
    }
  }

  Future<bool> removeFromWishlist(int productId) async {
    final headers = await _getHeaders();
    // API Route: Route::delete('/wishlist/{product_id}', ...)
    // Note: The param is product_id, NOT the wishlist primary key ID.
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/wishlist/$productId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 404) {
      // Not found in wishlist, effectively removed?
      return true;
    } else {
      throw Exception('Failed to remove from wishlist: ${response.body}');
    }
  }
}
