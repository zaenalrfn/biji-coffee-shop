import '../../core/constants/api_constants.dart';

class StoreModel {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String openTime;
  final String closeTime;
  final String? image;
  double? distance; // Calculated on frontend

  StoreModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.openTime,
    required this.closeTime,
    this.image,
    this.distance,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    String? imageUrl = json['image_url'] ?? json['image'];
    if (imageUrl != null && imageUrl.contains('0.0.0.0')) {
      // Replace 0.0.0.0 with the configured API host
      final apiUri = Uri.parse(ApiConstants.baseUrl);
      imageUrl = imageUrl.replaceFirst('0.0.0.0', apiUri.host);
    }

    return StoreModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: json['latitude'] is double
          ? json['latitude']
          : double.parse(json['latitude'].toString()),
      longitude: json['longitude'] is double
          ? json['longitude']
          : double.parse(json['longitude'].toString()),
      openTime: json['open_time'] ?? '',
      closeTime: json['close_time'] ?? '',
      image: imageUrl,
    );
  }

  String get operatingHours => '$openTime - $closeTime';
}
