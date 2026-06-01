class ShippingAddressModel {
  final String name;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String phone;

  ShippingAddressModel({
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'phone': phone,
    };
  }

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json) {
    return ShippingAddressModel(
      name: json['name'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      country: json['country'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

class OrderItemModel {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String image;

  OrderItemModel({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.image,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['product']?['_id'] ?? json['product'] ?? json['productId'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: json['image'] ?? '',
    );
  }
}

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItemModel> items;
  final double totalPrice;
  final String status;
  final ShippingAddressModel shippingAddress;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.shippingAddress,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['user'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      shippingAddress: ShippingAddressModel.fromJson(json['shippingAddress'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
