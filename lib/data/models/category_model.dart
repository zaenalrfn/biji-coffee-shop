class Category {
  final int id;
  final String name;
  final String? image;
  final String? iconName;

  Category({
    required this.id,
    required this.name,
    this.image,
    this.iconName,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      image: json['image'],
      iconName: json['icon_name'], // Mapped from Laravel
    );
  }
}
