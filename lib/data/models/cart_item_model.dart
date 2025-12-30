import 'product_model.dart';

class CartItem {
  final int id;
  final int productId;
  final int quantity;
  final double price; // Snapshot price
  final String? size;
  final Product? product;

  CartItem({
    required this.id,
    required this.productId,
    required this.quantity,
    this.price = 0.0,
    this.size,
    this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      productId: json['product_id'] is int
          ? json['product_id']
          : int.parse(json['product_id'].toString()),
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.parse(json['quantity'].toString()),
      price: json['price'] != null
          ? (json['price'] is num
              ? (json['price'] as num).toDouble()
              : double.tryParse(json['price'].toString()) ?? 0.0)
          : 0.0,
      size: json['size'],
      product:
          json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }
}
