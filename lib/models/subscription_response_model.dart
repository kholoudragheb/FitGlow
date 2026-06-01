class Subscription {
  final String id;
  final String planId;
  final String planName;
  final double price;
  final String currency;
  final String interval;
  final String status;
  final String coachId;
  final DateTime startDate;
  final DateTime currentPeriodEnd;

  Subscription({
    required this.id,
    required this.planId,
    required this.planName,
    required this.price,
    required this.currency,
    required this.interval,
    required this.status,
    required this.coachId,
    required this.startDate,
    required this.currentPeriodEnd,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? '',
      planId: json['planId'] ?? '',
      planName: json['planName'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? '',
      interval: json['interval'] ?? '',
      status: json['status'] ?? '',
      coachId: json['coachId'] ?? '',
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate']) ?? DateTime.now() : DateTime.now(),
      currentPeriodEnd: json['currentPeriodEnd'] != null ? DateTime.tryParse(json['currentPeriodEnd']) ?? DateTime.now() : DateTime.now(),
    );
  }
}

class SubscriptionResponse {
  final bool success;
  final Subscription? subscription;
  // Fallback map parsing if User doesn't map cleanly into the full UserModel instantly right here
  final Map<String, dynamic>? rawUserMap; 

  SubscriptionResponse({
    required this.success,
    this.subscription,
    this.rawUserMap,
  });

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponse(
      success: json['success'] ?? false,
      subscription: json['subscription'] != null ? Subscription.fromJson(json['subscription']) : null,
      rawUserMap: json['user'],
    );
  }
}

class CancelSubscriptionResponse {
  final bool success;
  final String message;
  final String status;

  CancelSubscriptionResponse({
    required this.success,
    required this.message,
    required this.status,
  });

  factory CancelSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return CancelSubscriptionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 'canceled',
    );
  }
}
