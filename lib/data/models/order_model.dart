import 'cart_item_model.dart';
import 'user_model.dart';
import 'driver_model.dart';

class Order {
  final int id;
  final String orderNumber;
  final double totalPrice;
  final String status;
  final String createdAt;
  final List<CartItem>? items;

  // New Fields for Admin/Detailed view
  final User? user;
  final String? paymentMethod;
  final String? paymentStatus;
  final Map<String, dynamic>? shippingAddress;
  final int? driverId;
  final Driver? driver;

  Order({
    required this.id,
    required this.orderNumber,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.items,
    this.user,
    this.paymentMethod,
    this.paymentStatus,
    this.shippingAddress,
    this.driverId,
    this.driver,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsList = <CartItem>[];
    if (json['items'] != null) {
      json['items'].forEach((v) {
        itemsList.add(CartItem.fromJson(v));
      });
    }

    return Order(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      orderNumber: json['transaction_id'] ??
          json['order_number'] ??
          '', // Handle both keys
      totalPrice: json['total_price'] is num
          ? (json['total_price'] as num).toDouble()
          : double.tryParse(json['total_price'].toString()) ?? 0.0,
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? '',
      items: itemsList,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      shippingAddress: json['shipping_address'] is Map<String, dynamic>
          ? json['shipping_address']
          : null,
      driverId: json['driver_id'] is int
          ? json['driver_id']
          : int.tryParse(json['driver_id'].toString()),
      driver: json['driver'] != null ? Driver.fromJson(json['driver']) : null,
    );
  }

  Order copyWith({
    int? id,
    String? orderNumber,
    double? totalPrice,
    String? status,
    String? createdAt,
    List<CartItem>? items,
    User? user,
    String? paymentMethod,
    String? paymentStatus,
    Map<String, dynamic>? shippingAddress,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      user: user ?? this.user,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      shippingAddress: shippingAddress ?? this.shippingAddress,
    );
  }
}
