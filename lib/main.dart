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
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7F6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF176B52),
        ),
        fontFamily: 'Roboto',
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

  static const Color primaryGreen = Color(0xFF176B52);
  static const Color darkText = Color(0xFF17221E);
  static const Color background = Color(0xFFF5F7F6);

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

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () async {
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
      },
    );
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
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Discover Products',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: darkText,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: searchProducts,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 15,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: primaryGreen,
                    ),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              searchController.clear();
                              searchProducts('');

                              setState(() {});
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 17,
                      horizontal: 10,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryGreen,
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 55,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 15),
            Text(
              errorMessage!,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: loadProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return const Center(
        child: Text(
          'No products found',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: primaryGreen,
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
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 30),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.70,
          ),
          itemCount: products.length + (isLoadingMore ? 2 : 0),
          itemBuilder: (context, index) {
            if (index >= products.length) {
              return const Center(
                child: CircularProgressIndicator(
                  color: primaryGreen,
                ),
              );
            }

            final product = products[index];

            return buildProductCard(product);
          },
        ),
      ),
    );
  }

  Widget buildProductCard(Product product) {
    return GestureDetector(
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PRODUCT IMAGE
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F5F4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    product.thumbnail,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.image_not_supported_outlined,
                        size: 45,
                        color: Colors.grey.shade400,
                      );
                    },
                  ),
                ),
              ),
            ),

            // PRODUCT INFO
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                        height: 1.25,
                      ),
                    ),

                    const Spacer(),

                    // RATING
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 17,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${product.rating}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // PRICE
                    Text(
                      '\$${product.price}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}