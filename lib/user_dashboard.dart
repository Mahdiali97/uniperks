import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uniperks/auth/login_page.dart';
import 'package:uniperks/pages/product_catalog_page.dart';
import 'package:uniperks/pages/cart_page.dart';
import 'package:uniperks/pages/quiz_page.dart';
import 'package:uniperks/pages/voucher_page.dart';
import 'package:uniperks/services/cart_service.dart';
import 'package:uniperks/services/user_coins_service.dart';
import 'package:uniperks/services/product_service.dart';
import 'package:uniperks/models/product.dart';

class UserDashboard extends StatefulWidget {
  final String username;

  const UserDashboard({super.key, required this.username});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;
  late Future<int> _coinsFuture;
  late Future<int> _cartFuture;
  // Reload counters to force remount of each tab when refreshed
  final List<int> _reloadCounters = [0, 0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    _refreshCoinsAndCart();
  }

  void _refreshCoinsAndCart() {
    setState(() {
      _coinsFuture = UserCoinsService.getCoins(widget.username);
      _cartFuture = CartService.getTotalItems(widget.username);
    });
  }

  // Refresh only the currently visible page and update header counters
  void _reloadCurrentPage() {
    setState(() {
      _reloadCounters[_selectedIndex]++;
      _coinsFuture = UserCoinsService.getCoins(widget.username);
      _cartFuture = CartService.getTotalItems(widget.username);
    });
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<List<Product>> _getFilteredProducts() async {
    final allProducts = await ProductService.getAllProducts();
    return allProducts;
  }

  Widget _buildHomePage() {
    return FutureBuilder<List<Product>>(
      future: _getFilteredProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final filteredProducts = snapshot.data ?? [];

        return RefreshIndicator(
          onRefresh: _onRefreshHome,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Banner Section
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 280,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 22, 56, 71),
                            const Color.fromARGB(255, 5, 55, 98),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'A Place to Shop UPSI Merchandise',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
                                        color: const Color(0xFF0066CC),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'GRAB\nYOURS NOW',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Popular Products
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Products',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 500,
                  child: _ProductSlideshow(
                    products: filteredProducts,
                    itemBuilder: _buildProductCard,
                  ),
                ),

                const SizedBox(height: 24),

                // Stats Section - Now using FutureBuilder
                _buildStatsSection(),

                const SizedBox(height: 24),

                // Flash Sale Section
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Color(0xFF0066CC).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Color(0xFF0066CC).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.flash_on,
                            color: Color(0xFF0066CC),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Super Flash Sale',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Get exclusive deals today only!',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => setState(() => _selectedIndex = 1),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0066CC),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Shop Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onRefreshHome() async {
    // Re-fetch header counts and trigger a rebuild so FutureBuilder reloads products
    _refreshCoinsAndCart();
    await ProductService.getAllProducts();
    if (mounted) setState(() {});
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Coins stat with FutureBuilder
          Expanded(
            child: FutureBuilder<int>(
              future: _coinsFuture,
              builder: (context, coinsSnapshot) {
                final coins = coinsSnapshot.data ?? 0;
                return _buildStatCard(
                  'Coins',
                  '$coins',
                  Icons.monetization_on,
                  Colors.amber,
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // Cart stat with FutureBuilder
          Expanded(
            child: FutureBuilder<int>(
              future: _cartFuture,
              builder: (context, cartSnapshot) {
                final cartCount = cartSnapshot.data ?? 0;
                return _buildStatCard(
                  'Cart',
                  '$cartCount',
                  Icons.shopping_cart,
                  Colors.blue,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                color: Colors.grey[100],
              ),
              child: Stack(
                children: [
                  Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.image, size: 40, color: Colors.grey),
                      );
                    },
                  ),
                  if (product.discount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${product.discount}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '\$${product.discountedPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0066CC),
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (product.discount > 0)
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      KeyedSubtree(
        key: ValueKey('home-${_reloadCounters[0]}'),
        child: _buildHomePage(),
      ), // Index 0 - Home
      ProductCatalogPage(
        key: ValueKey('catalog-${_reloadCounters[1]}'),
        username: widget.username,
      ), // Index 1 - Shop
      CartPage(
        key: ValueKey('cart-${_reloadCounters[2]}'),
        username: widget.username,
      ), // Index 2 - Cart
      QuizPage(
        key: ValueKey('quiz-${_reloadCounters[3]}'),
        username: widget.username,
      ), // Index 3 - Quiz
      VoucherPage(
        key: ValueKey('voucher-${_reloadCounters[4]}'),
        username: widget.username,
      ), // Index 4 - Vouchers
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo/UniPerks.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'UniPerks',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF0066CC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: _reloadCurrentPage,
          ),
          // Coins display with FutureBuilder
          FutureBuilder<int>(
            future: _coinsFuture,
            builder: (context, snapshot) {
              final coins = snapshot.data ?? 0;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$coins',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Cart badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 2; // Navigate to cart (index 2)
                  });
                },
              ),
              if (true) // Badge will be updated via FutureBuilder in CartPage
                Positioned(
                  right: 8,
                  top: 8,
                  child: FutureBuilder<int>(
                    future: _cartFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data! > 0) {
                        return Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${snapshot.data}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          // Refresh coins and cart when navigating to home
          if (index == 0) {
            _refreshCoinsAndCart();
          }
        },
        selectedItemColor: Color(0xFF0066CC),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quiz'),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Vouchers',
          ),
        ],
      ),
    );
  }
}

// A modern auto-sliding product slideshow with fade/scale animations
class _ProductSlideshow extends StatefulWidget {
  final List<Product> products;
  final Widget Function(Product) itemBuilder;

  const _ProductSlideshow({required this.products, required this.itemBuilder});

  @override
  State<_ProductSlideshow> createState() => _ProductSlideshowState();
}

class _ProductSlideshowState extends State<_ProductSlideshow> {
  late final PageController _controller;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.92);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (widget.products.length <= 1) return; // no autoplay for single item
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_currentPage + 1) % widget.products.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage = next);
    });
  }

  @override
  void didUpdateWidget(covariant _ProductSlideshow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.products.length != widget.products.length) {
      _currentPage = 0;
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No products available',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: widget.products.length,
            itemBuilder: (context, index) {
              final product = widget.products[index];
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  double t = 1.0;
                  if (_controller.hasClients &&
                      _controller.position.haveDimensions) {
                    final page =
                        _controller.page ?? _controller.initialPage.toDouble();
                    t = (1 - ((page - index).abs() * 0.35)).clamp(0.7, 1.0);
                  }
                  return Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Opacity(
                        opacity: t,
                        child: Transform.scale(scale: t, child: child),
                      ),
                    ),
                  );
                },
                child: widget.itemBuilder(product),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.products.length, (i) {
            final selected = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: selected ? 24 : 8,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF0066CC) : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
