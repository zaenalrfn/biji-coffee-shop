import 'cart_item_model.dart';

class Order {
  final int id;
  final String orderNumber;
  final double totalPrice;
  final String status;
  final String createdAt;
  final List<CartItem>? items;

  Order({
    required this.id,
    required this.orderNumber,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.items,
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
      orderNumber: json['order_number'] ?? '',
      totalPrice: json['total_price'] is num
          ? (json['total_price'] as num).toDouble()
          : double.tryParse(json['total_price'].toString()) ?? 0.0,
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? '',
      items: itemsList,
    );
  }
}
