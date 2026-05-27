import 'package:flutter/material.dart';
import 'bag_page.dart';
import 'data/app_data.dart';
import 'services/firestore_service.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _firestoreService = FirestoreService();
  String selectedSize = '';
  Color selectedColor = const Color(0xFFA67C52);
  int _currentImageIndex = 0;

  List<String> get images {
    if (widget.product.images.isNotEmpty) return widget.product.images;
    if (widget.product.imageUrl.isNotEmpty) return [widget.product.imageUrl];
    return [];
  }

  @override
  void initState() {
    super.initState();
    if (widget.product.sizes.isNotEmpty) {
      selectedSize = widget.product.sizes.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

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
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BagPage()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel with peek effect
            SizedBox(
              height: 350,
              child: PageView.builder(
                itemCount: images.length,
                controller: PageController(viewportFraction: 0.8, initialPage: 0),
                onPageChanged: (index) {
                  setState(() => _currentImageIndex = index);
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: buildDecorationImage(images[index]),
                        color: Colors.grey[300],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
            // Pagination Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentImageIndex == index ? 10 : 8,
                  height: _currentImageIndex == index ? 10 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index ? Colors.black : Colors.grey.shade300,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            // Product Title and Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'serif',
                      ),
                    ),
                  ),
                  Text(
                    '\$${product.price}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (product.subtitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  product.subtitle,
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ),
            const SizedBox(height: 20),
            // Size Selection
            if (product.sizes.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text('Size', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: product.sizes.map((size) {
                    bool isSelected = selectedSize == size;
                    return GestureDetector(
                      onTap: () => setState(() => selectedSize = size),
                      child: Container(
                        margin: const EdgeInsets.only(right: 15),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: isSelected ? const Color(0xFF7B3F1B) : Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          color: isSelected ? const Color(0xFFF5EBDD) : Colors.transparent,
                        ),
                        child: Text(
                          size,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? const Color(0xFF7B3F1B) : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],
            // Color Selection
            if (product.colors.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text('Color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: product.colors.map((hexColor) {
                    final color = Color(hexColor);
                    return _buildColorOption(color);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 40),
            ],
            // Add to Bag Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _firestoreService.addToCart(CartItem(
                            id: '',
                            productId: product.id,
                            title: product.title,
                            subtitle: product.subtitle,
                            size: selectedSize,
                            price: product.price,
                            imageUrl: product.imageUrl,
                          ));
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const BagPage()),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7B3F1B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Add to Bag',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.bookmark_border, size: 28),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Description
            if (product.description.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  product.description,
                  style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.5),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color) {
    bool isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() => selectedColor = color),
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? const Color(0xFF7B3F1B) : Colors.transparent, width: 2),
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: color,
        ),
      ),
    );
  }
}
