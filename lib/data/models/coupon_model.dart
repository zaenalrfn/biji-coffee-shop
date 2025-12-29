class Coupon {
  final int? id;
  final String code;
  final String type; // 'percent' or 'fixed'
  final double value;
  final double minPurchase;
  final String? expiresAt;
  final bool isActive;

  Coupon({
    this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.minPurchase,
    this.expiresAt,
    this.isActive = true,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'],
      code: json['code'] ?? '',
      type: json['type'] ?? 'fixed',
      value: json['value'] is num
          ? (json['value'] as num).toDouble()
          : double.tryParse(json['value'].toString()) ?? 0.0,
      minPurchase: json['min_purchase'] is num
          ? (json['min_purchase'] as num).toDouble()
          : double.tryParse(json['min_purchase'].toString()) ?? 0.0,
      expiresAt: json['expires_at'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'type': type,
      'value': value,
      'min_purchase': minPurchase,
      'expires_at': expiresAt,
      'is_active': isActive,
    };
  }
}
