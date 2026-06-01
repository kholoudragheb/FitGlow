class CategoryModel {
  final String id;
  final String name;
  final String? image;
  final String? icon;
  final int? productsCount;

  CategoryModel({
    required this.id,
    required this.name,
    this.image,
    this.icon,
    this.productsCount,
  });

  factory CategoryModel.fromJson(dynamic json) {
    if (json is String) {
      return CategoryModel(
        id: json.toLowerCase(),
        name: json,
      );
    }
    
    return CategoryModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
      icon: json['icon']?.toString(),
      productsCount: json['productsCount'] is int ? json['productsCount'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'icon': icon,
      'productsCount': productsCount,
    };
  }
}
