import 'product_model.dart';

class CartItem {
  final int id;
  final int productId;
  final int quantity;
  final Product? product;

  CartItem({
    required this.id,
    required this.productId,
    required this.quantity,
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
      product:
          json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }
}
