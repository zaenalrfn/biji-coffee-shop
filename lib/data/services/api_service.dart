import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import 'package:image_picker/image_picker.dart'; // Import XFile
import '../../core/constants/api_constants.dart';

class ApiService {
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Auth
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

  Future<User> updateProfile(String name, String email) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/user'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Depending on API response structure, user might be in data['user'] or just data
      // Based on user PROMPT: 'user' => $user
      return User.fromJson(data['user']);
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/forgot-password'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send OTP: ${response.body}');
    }
  }

  Future<void> resetPassword(String email, String otp, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/reset-password'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'password': password,
        'password_confirmation': password,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to reset password');
    }
  }

  // Products & Categories
  Future<List<Category>> getCategories() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/categories'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Handle wrapped data { data: [...] } or direct array [...]
      final List list =
          (data is Map && data.containsKey('data')) ? data['data'] : data;
      return list.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<Product>> getProducts() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/products'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list =
          (data is Map && data.containsKey('data')) ? data['data'] : data;
      return list.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Helper for multipart requests
  Future<Product> _submitProduct(
      String method, String url, Map<String, String> fields,
      [XFile? imageFile]) async {
    final token = await getToken();
    var request = http.MultipartRequest(method, Uri.parse(url));

    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    request.fields.addAll(fields);

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: imageFile.name,
      );
      request.files.add(multipartFile);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to save product: ${response.body}');
    }
  }

  Future<Product> createProduct(Map<String, String> fields,
      [XFile? imageFile]) async {
    return _submitProduct(
        'POST', '${ApiConstants.baseUrl}/products', fields, imageFile);
  }

  Future<Product> updateProduct(int id, Map<String, String> fields,
      [XFile? imageFile]) async {
    // Laravels PUT with multipart has issues, commonly utilize POST with _method=PUT
    // or just POST to update endpoint if configured.
    // Standard Laravel approach for multipart update is POST with _method = PUT
    fields['_method'] = 'PUT';
    return _submitProduct(
        'POST', '${ApiConstants.baseUrl}/products/$id', fields, imageFile);
  }

  Future<void> deleteProduct(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/products/$id'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete product: ${response.body}');
    }
  }

  // Cart
  Future<List<CartItem>> getCart() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/cart'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list =
          (data is Map && data.containsKey('data')) ? data['data'] : data;
      return list.map((e) => CartItem.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load cart');
    }
  }

  Future<void> addToCart(int productId, int quantity) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/cart'),
      headers: headers,
      body: jsonEncode({'product_id': productId, 'quantity': quantity}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add to cart: ${response.body}');
    }
  }

  Future<void> removeFromCart(int cartId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/cart/$cartId'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to remove from cart');
    }
  }

  Future<void> updateCartItem(int cartId, int quantity, {String? notes}) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/cart/$cartId'),
      headers: headers,
      body: jsonEncode({
        'quantity': quantity,
        if (notes != null) 'notes': notes,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update cart item: ${response.body}');
    }
  }

  // Orders
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

  Future<void> createOrder({
    Map<String, dynamic>? shippingAddress,
    String? paymentMethod,
  }) async {
    final headers = await _getHeaders();
    final body = jsonEncode({
      if (shippingAddress != null) 'shipping_address': shippingAddress,
      if (paymentMethod != null) 'payment_method': paymentMethod,
    });

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/orders'),
      headers: headers,
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create order: ${response.body}');
    }
  }
}
