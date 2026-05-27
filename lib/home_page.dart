import 'package:flutter/material.dart';
import 'bag_page.dart';
import 'product_detail_page.dart';
import 'product_listing_page.dart';
import 'profile_page.dart';
import 'data/app_data.dart';
import 'services/firestore_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NAV SHELL
// ─────────────────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  static const _titles = ['SheStyle', 'Products', 'Wishlist', 'My Account'];

  @override
  Widget build(BuildContext context) {
    final isHome = _currentIndex == 0;

    return Scaffold(
      backgroundColor: Colors.white,
      // ── AppBar changes per tab ──────────────────────────────────────────
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isHome ? 80 : 60),
        child: Container(
          decoration: BoxDecoration(
            gradient: isHome
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE5D1C1), Colors.white],
                  )
                : null,
            color: isHome ? null : Colors.white,
            boxShadow: isHome
                ? null
                : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: isHome
                ? IconButton(
                    icon: const Icon(Icons.search, color: Colors.black, size: 28),
                    onPressed: () {},
                  )
                : null,
            title: Text(
              _titles[_currentIndex],
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: isHome ? 32 : 26,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5D2E17),
                fontStyle: isHome ? FontStyle.italic : FontStyle.normal,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black, size: 28),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BagPage()),
                ),
              ),
            ],
          ),
        ),
      ),
      // ── Body switches via IndexedStack (keeps each tab alive) ───────────
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeTab(),
          _ProductsTab(),
          _WishlistTab(),
          ProfileBody(),
        ],
      ),
      // ── Bottom Navigation Bar ───────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF7B3F1B),
        unselectedItemColor: Colors.black45,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined),      label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined),  label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border),     label: 'Wishlist'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline),      label: 'Profile'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 0 — HOME
// ─────────────────────────────────────────────────────────────────────────────

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final _firestoreService = FirestoreService();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _firestoreService.getProductsOnce();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          SizedBox(
            height: 200,
            child: PageView(
              children: [
                _buildBanner('assets/images/home/WhatsApp Image 2026-04-12 at 11.57.08 PM.jpeg'),
                _buildBanner('assets/images/home/Image 8.jpeg'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDot(false), _buildDot(false), _buildDot(true),
              _buildDot(false), _buildDot(false),
            ],
          ),
          const SizedBox(height: 20),
          // Categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: dummyCategories
                  .map((cat) => _buildCategoryItem(cat.name, cat.imageUrl, context))
                  .toList(),
            ),
          ),
          const SizedBox(height: 30),
          // Featured
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Featured',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'serif'),
            ),
          ),
          const SizedBox(height: 15),
          FutureBuilder<List<Product>>(
            future: _productsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final products = snapshot.data ?? [];
              final featured =
                  products.where((p) => featuredProductIds.contains(p.id)).toList();
              if (featured.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: featured.asMap().entries.map((entry) {
                    return [
                      if (entry.key > 0) const SizedBox(width: 20),
                      Expanded(
                        child: _buildProductCard(
                          entry.value.title,
                          '\$${entry.value.price}',
                          entry.value.imageUrl,
                        ),
                      ),
                    ];
                  }).expand((w) => w).toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildBanner(String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Exclusive\nLine',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Shop Now', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.black : Colors.black12,
        ),
      );

  Widget _buildCategoryItem(String title, String imagePath, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductListingPage(category: title)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: AssetImage(imagePath),
          ),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'serif')),
        ],
      ),
    );
  }

  Widget _buildProductCard(String title, String price, String imagePath) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: buildImage(imagePath, height: 180, width: double.infinity),
        ),
        const SizedBox(height: 10),
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 5),
        Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1 — ALL PRODUCTS
// ─────────────────────────────────────────────────────────────────────────────

class _ProductsTab extends StatefulWidget {
  const _ProductsTab();

  @override
  State<_ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<_ProductsTab> {
  final _firestoreService = FirestoreService();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _firestoreService.getProductsOnce();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final products = snapshot.data ?? [];
        if (products.isEmpty) {
          return const Center(
            child: Text('No products found',
                style: TextStyle(fontSize: 16, color: Colors.black54)),
          );
        }
        return GridView.count(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: products.map((product) {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: buildDecorationImage(product.imageUrl),
                        color: Colors.grey[300],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(product.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${product.price}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const Icon(Icons.shopping_bag_outlined, size: 20),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2 — WISHLIST
// ─────────────────────────────────────────────────────────────────────────────

class _WishlistTab extends StatelessWidget {
  const _WishlistTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.black26),
          SizedBox(height: 20),
          Text('Your wishlist is empty',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54)),
          SizedBox(height: 10),
          Text('Save items you love here',
              style: TextStyle(fontSize: 14, color: Colors.black38)),
        ],
      ),
    );
  }
}
