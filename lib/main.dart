import 'dart:async';

import 'package:flutter/material.dart';
import 'services/product_service.dart';
import 'models/product.dart';
import 'product_detail_screen.dart';

void main() {
  runApp(const ProductCatalogApp());
}

class ProductCatalogApp extends StatelessWidget {
  const ProductCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Product Catalog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ProductListScreen(),
    );
  }
}

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductService productService = ProductService();
  final TextEditingController searchController = TextEditingController();

  List<Product> products = [];

  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  bool isSearching = false;

  String? errorMessage;
  int skip = 0;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      final newProducts = await productService.getProducts(skip);

      setState(() {
        products.addAll(newProducts);
        isLoading = false;
        isLoadingMore = false;

        if (newProducts.length < 20) {
          hasMore = false;
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load products';
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  Future<void> loadMoreProducts() async {
    if (isLoadingMore || !hasMore || isSearching) {
      return;
    }

    setState(() {
      isLoadingMore = true;
    });

    skip += 20;

    await loadProducts();
  }

  Future<void> refreshProducts() async {
    setState(() {
      products = [];
      skip = 0;
      hasMore = true;
      errorMessage = null;
      isSearching = false;
    });

    await loadProducts();
  }

  void searchProducts(String query) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.trim().isEmpty) {
        setState(() {
          isSearching = false;
          products = [];
          skip = 0;
          hasMore = true;
          isLoading = true;
          errorMessage = null;
        });

        await loadProducts();
        return;
      }

      setState(() {
        isSearching = true;
        isLoading = true;
        errorMessage = null;
      });

      try {
        final results =
            await productService.searchProducts(query.trim());

        setState(() {
          products = results;
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          errorMessage = 'Failed to search products';
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: searchProducts,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          searchProducts('');
                          setState(() {});
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: buildBody(),
          ),
        ],
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: loadProducts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return const Center(
        child: Text('No products found'),
      );
    }

    return RefreshIndicator(
      onRefresh: refreshProducts,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (!isSearching &&
              notification is ScrollEndNotification &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 200) {
            loadMoreProducts();
          }

          return false;
        },
        child: ListView.builder(
          itemCount: products.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == products.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final product = products[index];

            return ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(
                      product: product,
                    ),
                  ),
                );
              },
              leading: Image.network(
                product.thumbnail,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported,
                    size: 40,
                  );
                },
              ),
              title: Text(product.title),
              subtitle: Text('\$${product.price}'),
            );
          },
        ),
      ),
    );
  }
}