class Product {
  final int id;
  final String name;
  final String? subtitle;
  final String description;
  final double price;
  final String? imageUrl;
  final int categoryId;
  final String? categoryName;

  Product({
    required this.id,
    required this.name,
    this.subtitle,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.categoryId,
    this.categoryName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? json['title'] ?? '',
      subtitle: json['subtitle'],
      description: json['description'] ?? '',
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price'].toString()) ?? 0.0,
      imageUrl:
          json['image_url'] ?? json['image'], // Handle inconsistent naming
      categoryId: json['category_id'] is int
          ? json['category_id']
          : int.tryParse(json['category_id'].toString()) ?? 0,
      categoryName: json['category'] != null ? json['category']['name'] : null,
    );
  }
}
