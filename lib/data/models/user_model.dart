class User {
  final int id;
  final String name;
  final String email;
  final String? profilePhotoUrl;
  final List<String> roles; // Added roles

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePhotoUrl,
    this.roles = const [], // Default empty list
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profilePhotoUrl: json['profile_photo_url'],
      roles: json['roles'] != null
          ? List<String>.from(json['roles'])
          : [], // Parse roles
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_photo_url': profilePhotoUrl,
      'roles': roles, // Serialize roles
    };
  }
}
