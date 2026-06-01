import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/review_model.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';
import '../utils/token_storage.dart';

class StoreService {
  final String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';
  final Duration _timeout = const Duration(seconds: 15);

  Future<List<ProductModel>> getAllProducts({String? category, String? search}) async {
    final queryParams = <String, String>{};
    if (category != null && category != 'All') {
      queryParams['category'] = category;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final uri = Uri.parse('$baseUrl/products').replace(queryParameters: queryParams);
    final token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Fetching products...");
      print("URL: $uri");
    }

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      if (kDebugMode) {
        print("Products Status: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final List productsData = (data is List) 
            ? data 
            : (data is Map ? (data['products'] ?? data['data'] ?? []) : []);
        return productsData.map((p) => ProductModel.fromJson(p)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized — please log in again.');
      } else {
        throw Exception('Server error (${response.statusCode})');
      }
    } on SocketException {
      throw Exception('No internet connection.');
    } catch (e) {
      debugPrint('[StoreService] Error fetching products: $e');
      rethrow;
    }
  }

  Future<List<CategoryModel>> getProductCategories() async {
    final uri = Uri.parse('$baseUrl/products/categories');
    final token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Fetching product categories...");
      print("URL: $uri");
    }

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      if (kDebugMode) {
        print("Categories Status: ${response.statusCode}");
        print("Categories Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final List categoriesData = data is List 
            ? data 
            : (data['categories'] ?? data['data'] ?? []);
        
        return categoriesData.map((c) => CategoryModel.fromJson(c)).toList();
      } else {
        throw Exception('Failed to load categories (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('[StoreService] Error fetching categories: $e');
      rethrow;
    }
  }

  Future<ProductModel> getProductById(String productId) async {
    final uri = Uri.parse('$baseUrl/products/$productId');
    final token = await TokenStorage.getAccessToken();

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final productData = (data is Map) ? (data['product'] ?? data['data'] ?? data) : data;
        return ProductModel.fromJson(productData);
      } else {
        throw Exception('Product not found.');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ReviewModel> addProductReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    final uri = Uri.parse('$baseUrl/products/$productId/review');
    final token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Submitting product review...");
      print("URL: $uri");
    }

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'rating': rating,
          'comment': comment,
        }),
      ).timeout(_timeout);

      if (kDebugMode) {
        print("Review Status: ${response.statusCode}");
        print("Review Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = jsonDecode(response.body);
        final reviewData = (data is Map) ? (data['review'] ?? data['data'] ?? data) : data;
        return ReviewModel.fromJson(reviewData);
      } else {
        final dynamic data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to submit review (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('[StoreService] Error submitting review: $e');
      rethrow;
    }
  }

  Future<CartModel> addToCart({
    required String productId,
    required int quantity,
  }) async {
    final uri = Uri.parse('$baseUrl/cart/add');
    final token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Adding product to cart...");
      print("URL: $uri");
      print("Payload: ${jsonEncode({'productId': productId, 'quantity': quantity})}");
    }

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'productId': productId,
          'quantity': quantity,
        }),
      ).timeout(_timeout);

      if (kDebugMode) {
        print("Add To Cart Status: ${response.statusCode}");
        print("Add To Cart Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = jsonDecode(response.body);
        final cartData = (data is Map) ? (data['cart'] ?? data['data'] ?? data) : data;
        return CartModel.fromJson(cartData);
      } else {
        final dynamic data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to add to cart (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('[StoreService] Error adding to cart: $e');
      rethrow;
    }
  }

  Future<OrderModel> getOrderById({
    required String orderId,
  }) async {
    final uri = Uri.parse('$baseUrl/orders/$orderId');
    final token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Fetching order by ID...");
      print("URL: $uri");
    }

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      if (kDebugMode) {
        print("Fetch Order Detail Status: ${response.statusCode}");
        print("Fetch Order Detail Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final orderData = (data is Map) ? (data['order'] ?? data['data'] ?? data) : data;
        return OrderModel.fromJson(orderData);
      } else {
        final dynamic data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to fetch order details (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('[StoreService] Error fetching order details: $e');
      rethrow;
    }
  }

  Future<List<OrderModel>> getMyOrders() async {
    final uri = Uri.parse('$baseUrl/orders');
    final token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Fetching orders...");
      print("URL: $uri");
    }

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      if (kDebugMode) {
        print("Fetch Orders Status: ${response.statusCode}");
        print("Fetch Orders Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final List ordersList = (data is List) 
            ? data 
            : (data is Map ? (data['orders'] ?? data['data'] ?? []) : []);
        return ordersList.map((o) => OrderModel.fromJson(o)).toList();
      } else {
        final dynamic data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to fetch orders (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('[StoreService] Error fetching orders: $e');
      rethrow;
    }
  }

  Future<OrderModel> checkoutCart({
    required ShippingAddressModel shippingAddress,
  }) async {
    final uri = Uri.parse('$baseUrl/cart/checkout');
    final token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Starting checkout...");
      print("URL: $uri");
    }

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'shippingAddress': shippingAddress.toJson(),
        }),
      ).timeout(_timeout);

      if (kDebugMode) {
        print("Checkout Status: ${response.statusCode}");
        print("Checkout Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = jsonDecode(response.body);
        final orderData = (data is Map) ? (data['order'] ?? data['data'] ?? data) : data;
        return OrderModel.fromJson(orderData);
      } else {
        final dynamic data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to complete checkout (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('[StoreService] Error during checkout: $e');
      rethrow;
    }
  }

  Future<CartModel> clearCart() async {
    final uri = Uri.parse('$baseUrl/cart/clear');
    final token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Clearing cart...");
      print("URL: $uri");
    }

    try {
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      if (kDebugMode) {
        print("Clear Cart Status: ${response.statusCode}");
        print("Clear Cart Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final cartData = (data is Map) ? (data['cart'] ?? data['data'] ?? data) : data;
        return CartModel.fromJson(cartData);
      } else {
        final dynamic data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to clear cart (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('[StoreService] Error clearing cart: $e');
      rethrow;
    }
  }

  Future<CartModel> removeFromCart({
    required String productId,
  }) async {
    final uri = Uri.parse('$baseUrl/cart/item/$productId');
    final token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Removing item from cart...");
      print("URL: $uri");
    }

    try {
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      if (kDebugMode) {
        print("Remove From Cart Status: ${response.statusCode}");
        print("Remove From Cart Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final cartData = (data is Map) ? (data['cart'] ?? data['data'] ?? data) : data;
        return CartModel.fromJson(cartData);
      } else {
        final dynamic data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to remove item (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('[StoreService] Error removing from cart: $e');
      rethrow;
    }
  }

  Future<CartModel> updateCartItem({
    required String productId,
    required int quantity,
  }) async {
    final uri = Uri.parse('$baseUrl/cart/item/$productId');
    final token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Updating cart item...");
      print("URL: $uri");
      print("Quantity: $quantity");
    }

    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'quantity': quantity}),
      ).timeout(_timeout);

      if (kDebugMode) {
        print("Update Cart Status: ${response.statusCode}");
        print("Update Cart Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final cartData = (data is Map) ? (data['cart'] ?? data['data'] ?? data) : data;
        return CartModel.fromJson(cartData);
      } else {
        final dynamic data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to update quantity (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('[StoreService] Error updating cart item: $e');
      rethrow;
    }
  }

  Future<CartModel> getCart() async {
    final uri = Uri.parse('$baseUrl/cart');
    final token = await TokenStorage.getAccessToken();

    if (kDebugMode) {
      print("Fetching cart...");
      print("URL: $uri");
    }

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      if (kDebugMode) {
        print("Cart Status: ${response.statusCode}");
        print("Cart Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final cartData = (data is Map) ? (data['cart'] ?? data['data'] ?? data) : data;
        return CartModel.fromJson(cartData);
      } else if (response.statusCode == 404) {
        return CartModel(
          id: '',
          userId: '',
          items: [],
          totalPrice: 0.0,
          subtotal: 0.0,
          updatedAt: DateTime.now(),
        );
      } else {
        throw Exception('Failed to load cart (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('[StoreService] Error fetching cart: $e');
      rethrow;
    }
  }
}
