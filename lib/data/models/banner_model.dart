class BannerModel {
  final int id;
  final String name;
  final String? imageUrl;

  BannerModel({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      imageUrl:
          json['image_url'] ?? json['image'], // Handle both potential keys
    );
  }
}
