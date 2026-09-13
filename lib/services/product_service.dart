import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  final String baseUrl = 'https://dummyjson.com';

  Future<List<Product>> getProducts(int skip) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products?limit=20&skip=$skip'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List products = data['products'];

      return products
          .map((json) => Product.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/search?q=$query'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List products = data['products'];

      return products
          .map((json) => Product.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to search products');
    }
  }
}