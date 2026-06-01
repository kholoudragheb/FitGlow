
class CartItemModel {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final double totalItemPrice;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.totalItemPrice,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    // Handle both flat structures and nested product structures
    final product = json['product'] ?? {};
    return CartItemModel(
      id: json['_id'] ?? json['id'] ?? '',
      productId: product['_id'] ?? product['id'] ?? json['productId'] ?? '',
      productName: product['name'] ?? json['productName'] ?? json['name'] ?? '',
      productImage: (product['images'] != null && product['images'].isNotEmpty)
          ? product['images'][0]
          : (json['productImage'] ?? json['image'] ?? ''),
      price: (json['price'] as num?)?.toDouble() ?? (product['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 1,
      totalItemPrice: (json['totalItemPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}

class CartModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final double totalPrice;
  final double subtotal;
  final double discount;
  final double tax;
  final String currency;
  final DateTime updatedAt;

  CartModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.subtotal,
    this.discount = 0.0,
    this.tax = 0.0,
    this.currency = 'USD',
    required this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['user'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((item) => CartItemModel.fromJson(item))
          .toList(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
