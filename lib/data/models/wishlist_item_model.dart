import 'package:flutter/foundation.dart';
import 'product_model.dart';

class WishlistItem {
  final int id;
  final int userId;
  final int productId;
  final DateTime createdAt;
  final Product product;

  WishlistItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.createdAt,
    required this.product,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.parse(json['user_id'].toString()),
      productId: json['product_id'] is int
          ? json['product_id']
          : int.parse(json['product_id'].toString()),
      createdAt: DateTime.parse(json['created_at']),
      product: Product.fromJson(json['product']),
    );
  }
}
