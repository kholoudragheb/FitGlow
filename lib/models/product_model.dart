class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String currency;
  final int stock;
  final String category;
  final String brand;
  final List<String> images;
  final double rating;
  final int reviewsCount;
  final List<String> tags;
  final Map<String, String>? specifications;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.currency,
    required this.stock,
    required this.category,
    required this.brand,
    required this.images,
    required this.rating,
    required this.reviewsCount,
    required this.tags,
    this.specifications,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: (json['salePrice'] as num?)?.toDouble() ?? (json['discountPrice'] as num?)?.toDouble(),
      currency: json['currency'] ?? 'USD',
      stock: json['stock'] ?? 0,
      category: json['category'] ?? 'General',
      brand: json['brand'] ?? 'Fit Glow',
      images: List<String>.from(json['images'] ?? []),
      rating: (json['averageRating'] as num?)?.toDouble() ?? (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviewCount'] ?? json['reviewsCount'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      specifications: json['specifications'] != null 
          ? Map<String, String>.from(json['specifications']) 
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'currency': currency,
      'stock': stock,
      'category': category,
      'brand': brand,
      'images': images,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'tags': tags,
      'specifications': specifications,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
