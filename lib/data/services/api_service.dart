import 'dart:convert';
// import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/banner_model.dart';
import '../models/store_model.dart';
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

  Future<User> updateProfile(
      String name, String email, XFile? imageFile) async {
    final token = await getToken();
    // Using POST with _method: PUT is standard for Laravel file uploads on update
    var uri = Uri.parse('${ApiConstants.baseUrl}/user');
    // If the route is specifically POST for update, we don't need _method: PUT.
    // But usually /user is PUT. Laravel can't handle multipart on PUT directly.
    // So we use POST and spoof PUT.
    var request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['_method'] = 'PUT'; // Method spoofing

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'image', // Field name expected by backend
        bytes,
        filename: imageFile.name,
      ));
    }

    final streamdResponse = await request.send();
    final response = await http.Response.fromStream(streamdResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Ensure we parse the user correctly. Sometimes it's directly in data or data['data'] or data['user']
      // Based on previous code: return User.fromJson(data['user']);
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

  Future<Category> createCategory(String name, {String? iconName}) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/categories'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'icon_name': iconName, // Send to backend
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final catData =
          (data is Map && data.containsKey('data')) ? data['data'] : data;
      return Category.fromJson(catData);
    } else {
      throw Exception('Failed to create category: ${response.body}');
    }
  }

  Future<Category> updateCategory(int id, String name,
      {String? iconName}) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/categories/$id'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'icon_name': iconName, // Send to backend
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final catData =
          (data is Map && data.containsKey('data')) ? data['data'] : data;
      return Category.fromJson(catData);
    } else {
      throw Exception('Failed to update category: ${response.body}');
    }
  }

  Future<void> deleteCategory(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/categories/$id'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete category: ${response.body}');
    }
  }

  // ================= BANNERS =================

  Future<List<BannerModel>> getBanners() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/banners'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list =
          (data is Map && data.containsKey('data')) ? data['data'] : data;
      return list.map((e) => BannerModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load banners');
    }
  }

  Future<BannerModel> createBanner({
    required String name,
    XFile? imageFile,
    String? imageUrl,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('${ApiConstants.baseUrl}/banners');

    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll(headers);
    request.fields['name'] = name;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      request.fields['image_url'] = imageUrl;
    }

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: imageFile.name,
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final bannerData =
          (data is Map && data.containsKey('data')) ? data['data'] : data;
      return BannerModel.fromJson(bannerData);
    } else {
      throw Exception('Failed to create banner: ${response.body}');
    }
  }

  Future<BannerModel> updateBanner({
    required int id,
    required String name,
    XFile? imageFile,
    String? imageUrl,
  }) async {
    final headers = await _getHeaders();
    // Note: Use POST with _method=PUT or straight PUT if endpoints support multipart on PUT.
    // Laravel often needs POST with _method=PUT for multipart updates.
    // Postman collection says POST for Update Banner.
    final uri = Uri.parse('${ApiConstants.baseUrl}/banners/$id');

    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll(headers);
    request.fields['name'] = name;
    // Removed _method = PUT as per user feedback (Endpoint is POST)

    if (imageUrl != null && imageUrl.isNotEmpty) {
      request.fields['image_url'] = imageUrl;
    }

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: imageFile.name,
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final bannerData =
          (data is Map && data.containsKey('data')) ? data['data'] : data;
      return BannerModel.fromJson(bannerData);
    } else {
      throw Exception('Failed to update banner: ${response.body}');
    }
  }

  Future<void> deleteBanner(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/banners/$id'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete banner: ${response.body}');
    }
  }

  // ================= STORE CRUD =================
  Future<List<StoreModel>> getStores() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/stores'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List storesData =
          (data is Map && data.containsKey('data')) ? data['data'] : data;
      return storesData.map((e) => StoreModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load stores: ${response.body}');
    }
  }

  Future<StoreModel> createStore({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required String openTime,
    required String closeTime,
    XFile? imageFile,
  }) async {
    final token = await getToken();
    var uri = Uri.parse('${ApiConstants.baseUrl}/stores');
    var request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    request.fields['name'] = name;
    request.fields['address'] = address;
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    request.fields['open_time'] = openTime;
    request.fields['close_time'] = closeTime;

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: imageFile.name,
      ));
    }

    final streamdResponse = await request.send();
    final response = await http.Response.fromStream(streamdResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final storeData =
          (data is Map && data.containsKey('data')) ? data['data'] : data;
      return StoreModel.fromJson(storeData);
    } else {
      throw Exception('Failed to create store: ${response.body}');
    }
  }

  Future<StoreModel> updateStore({
    required int id,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required String openTime,
    required String closeTime,
    XFile? imageFile,
  }) async {
    final token = await getToken();
    var uri = Uri.parse('${ApiConstants.baseUrl}/stores/$id');
    var request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    request.fields['name'] = name;
    request.fields['address'] = address;
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();
    request.fields['open_time'] = openTime;
    request.fields['close_time'] = closeTime;

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: imageFile.name,
      ));
    }

    final streamdResponse = await request.send();
    final response = await http.Response.fromStream(streamdResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final storeData =
          (data is Map && data.containsKey('data')) ? data['data'] : data;
      return StoreModel.fromJson(storeData);
    } else {
      throw Exception('Failed to update store: ${response.body}');
    }
  }

  Future<void> deleteStore(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/stores/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete store: ${response.body}');
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

  // Admin: Get All Orders
  Future<List<Order>> getAdminOrders() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/orders'), // Corrected Endpoint
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list =
          (data is Map && data.containsKey('data')) ? data['data'] : data;
      return list.map((e) => Order.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load admin orders: ${response.body}');
    }
  }

  // Admin: Update Order Status
  Future<Order> updateOrderStatus(int id, String status) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(
          '${ApiConstants.baseUrl}/admin/orders/$id'), // Corrected Endpoint
      headers: headers,
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Order.fromJson(data['data'] ?? data);
    } else {
      throw Exception('Failed to update order status: ${response.body}');
    }
  }

  // Admin: Delete Order
  Future<void> deleteOrder(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/admin/orders/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete order: ${response.body}');
    }
  }

  // --- Coupons ---

  // User: Check Coupon
  Future<Map<String, dynamic>> checkCoupon(
      String code, double totalAmount) async {
    final headers = await _getHeaders();
    final body = jsonEncode({
      'code': code,
      'total_amount': totalAmount,
    });

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/check-coupon'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      // Expecting { "valid": true, "discount_amount": 1000, "coupon": {...} }
      return jsonDecode(response.body);
    } else {
      throw Exception('Invalid coupon or error: ${response.body}');
    }
  }

  // Admin: Get Coupons
  Future<List<dynamic>> getAdminCoupons() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/coupons'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);
      if (data is List) {
        return data; // Direct list
      } else if (data is Map &&
          data.containsKey('data') &&
          data['data'] is List) {
        return (data['data'] as List).toList(); // Wrapped in data
      }
      return []; // Fallback
    } else {
      throw Exception('Failed to load coupons');
    }
  }

  // Admin: Create Coupon
  Future<void> createCoupon(Map<String, dynamic> couponData) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/admin/coupons'),
      headers: headers,
      body: jsonEncode(couponData),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to create coupon: ${response.body}');
    }
  }

  // Admin: Delete Coupon
  Future<void> deleteCoupon(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/admin/coupons/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete coupon: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> createOrder({
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

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create order: ${response.body}');
    }
  }

  // ================= POINTS & REWARDS =================

  /// Get user's current PBC points
  Future<int> getUserPoints() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/points'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Handle different possible response formats
      if (data is Map && data.containsKey('points')) {
        return data['points'] as int;
      } else if (data is Map && data.containsKey('data')) {
        return data['data']['points'] as int;
      }
      return 0;
    } else {
      throw Exception('Failed to get user points: ${response.body}');
    }
  }

  /// Get rewards page data (challenge progress, etc.)
  Future<Map<String, dynamic>> getRewardsData() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/rewards'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get rewards data: ${response.body}');
    }
  }
}
