class Driver {
  final int id;
  final String name;
  final String? photoUrl;
  final String? phone;
  final double currentLat;
  final double currentLng;
  final bool isActive;
  final int? userId; // User ID dari tabel users (untuk authorization chat)

  Driver({
    required this.id,
    required this.name,
    this.photoUrl,
    this.phone,
    this.currentLat = 0.0,
    this.currentLng = 0.0,
    this.isActive = false,
    this.userId,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    // Handle nested user object if present
    final userData = json['user'] ?? {};
    final userName = json['name'] ?? userData['name'] ?? 'Unknown Driver';
    final userPhone = json['phone'] ?? userData['phone'];
    final userPhoto = json['photo_url'] ??
        json['image_url'] ??
        userData['photo_url'] ??
        userData['image_url'];

    return Driver(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: userName,
      photoUrl: userPhoto,
      phone: userPhone,
      userId: json['user_id'] is int
          ? json['user_id']
          : (json['user_id'] != null
              ? int.tryParse(json['user_id'].toString())
              : null),
      currentLat: json['current_lat'] is num
          ? (json['current_lat'] as num).toDouble()
          : double.tryParse(json['current_lat'].toString()) ?? 0.0,
      currentLng: json['current_lng'] is num
          ? (json['current_lng'] as num).toDouble()
          : double.tryParse(json['current_lng'].toString()) ?? 0.0,
      isActive: json['is_active'] is bool
          ? json['is_active']
          : (json['is_active'] == 1 || json['is_active'] == '1'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photo_url': photoUrl,
      'phone': phone,
      'user_id': userId,
      'current_lat': currentLat,
      'current_lng': currentLng,
      'is_active': isActive,
    };
  }
}
