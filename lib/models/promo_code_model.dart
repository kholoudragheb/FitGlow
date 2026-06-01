class PromoCodeModel {
  final bool valid;
  final String code;
  final String discountType; // 'percentage' or 'fixed'
  final double discountValue;
  final double finalPrice;
  final String message;
  final DateTime? expiresAt;
  final int? usageLimit;

  PromoCodeModel({
    required this.valid,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.finalPrice,
    required this.message,
    this.expiresAt,
    this.usageLimit,
  });

  factory PromoCodeModel.fromJson(Map<String, dynamic> json) {
    return PromoCodeModel(
      valid: json['valid'] ?? false,
      code: json['code']?.toString() ?? '',
      discountType: json['discountType']?.toString() ?? 'percentage',
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0.0,
      finalPrice: (json['finalPrice'] as num?)?.toDouble() ?? 0.0,
      message: json['message']?.toString() ?? '',
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt'].toString()) : null,
      usageLimit: (json['usageLimit'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valid': valid,
      'code': code,
      'discountType': discountType,
      'discountValue': discountValue,
      'finalPrice': finalPrice,
      'message': message,
      'expiresAt': expiresAt?.toIso8601String(),
      'usageLimit': usageLimit,
    };
  }
}
