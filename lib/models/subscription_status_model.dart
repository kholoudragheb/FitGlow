/// Holds the response from GET /payments/subscription-status
class SubscriptionStatusModel {
  final String subscriptionStatus; // "active" | "canceled" | "none"
  final String? subscribedCoachId;
  final String? subscriptionId;

  SubscriptionStatusModel({
    required this.subscriptionStatus,
    this.subscribedCoachId,
    this.subscriptionId,
  });

  bool get isActive => subscriptionStatus == 'active';
  bool get isCanceled => subscriptionStatus == 'canceled';

  factory SubscriptionStatusModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatusModel(
      subscriptionStatus: json['subscriptionStatus'] as String? ?? 'none',
      subscribedCoachId: json['subscribedCoachId'] as String?,
      subscriptionId: json['subscriptionId'] as String?,
    );
  }

  /// Fallback: not subscribed.
  factory SubscriptionStatusModel.none() {
    return SubscriptionStatusModel(subscriptionStatus: 'none');
  }

  @override
  String toString() =>
      'SubscriptionStatusModel(status: $subscriptionStatus, coachId: $subscribedCoachId, id: $subscriptionId)';
}
