import 'package:flutter/material.dart';
import 'bag_page.dart';
import 'product_detail_page.dart';
import 'data/app_data.dart';
import 'services/firestore_service.dart';

class ProductListingPage extends StatelessWidget {
  final String category;

  const ProductListingPage({super.key, this.category = 'Dresses'});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SheStyle',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5D2E17),
            fontStyle: FontStyle.italic,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BagPage()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              category,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 15),
            // Filter Bar
            Row(
              children: [
                _buildFilterButton('Filter', icon: Icons.tune),
                const SizedBox(width: 10),
                _buildFilterButton('Filter', hasDropdown: true),
                const SizedBox(width: 10),
                _buildFilterButton('Sorting', hasDropdown: true),
              ],
            ),
            const SizedBox(height: 20),
            // Product Grid
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: firestoreService.getProductsOnce(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final products = (snapshot.data ?? [])
                      .where((p) => p.category == category)
                      .toList();
                  return GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    children: products.map((product) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(product: product),
                            ),
                          );
                        },
                        child: _buildProductItem(product.title, '\$${product.price}', product.imageUrl),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text, {IconData? icon, bool hasDropdown = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 5),
          ],
          Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
          if (hasDropdown) ...[
            const SizedBox(width: 5),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ],
      ),
    );
  }

  Widget _buildProductItem(String title, String price, String imagePath) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: buildDecorationImage(imagePath),
              color: Colors.grey[300],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              price,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Icon(Icons.shopping_bag_outlined, size: 20),
          ],
        ),
      ],
    );
  }
}
