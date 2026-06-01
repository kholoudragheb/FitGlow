class SubscriptionPlan {
  final String id;
  final String name;
  final double price;
  final String currency;
  final String interval;
  final String priceId;
  final List<String> features;
  final bool isRecommended;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.interval,
    required this.priceId,
    required this.features,
    required this.isRecommended,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Plan',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      interval: json['interval']?.toString() ?? 'month',
      priceId: json['priceId']?.toString() ?? '',
      features: (json['features'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isRecommended: json['recommended'] == true,
    );
  }
}
