import 'package:flutter/material.dart';
import 'checkout_page.dart';
import 'data/app_data.dart';
import 'services/firestore_service.dart';

class BagPage extends StatefulWidget {
  const BagPage({super.key});

  @override
  State<BagPage> createState() => _BagPageState();
}

class _BagPageState extends State<BagPage> {
  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
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
      ),
      body: StreamBuilder<List<CartItem>>(
        stream: _firestoreService.getCart(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cartItems = snapshot.data ?? [];

          if (cartItems.isEmpty) {
            return const Center(
              child: Text('Your bag is empty', style: TextStyle(fontSize: 18, color: Colors.black54)),
            );
          }

          double subtotal = cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
          double shipping = 30.0;
          double total = subtotal + shipping;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Bag',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'serif',
                        ),
                      ),
                      Text(
                        '${cartItems.length} Items',
                        style: const TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Cart Items
                  ...List.generate(cartItems.length, (index) {
                    final item = cartItems[index];
                    return _buildBagItem(
                      index: index,
                      title: item.title,
                      subtitle: item.subtitle,
                      size: item.size,
                      price: '\$${item.price}',
                      imagePath: item.imageUrl,
                      quantity: item.quantity,
                      cartItemId: item.id,
                    );
                  }),
                  const SizedBox(height: 20),
                  // Summary
                  const Divider(thickness: 1),
                  _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}', isBold: true),
                  _buildSummaryRow('Shipping', '\$${shipping.toStringAsFixed(2)}', isBold: true),
                  const Divider(thickness: 1),
                  _buildSummaryRow('Total', '\$${total.toStringAsFixed(2)}', isBold: true, fontSize: 18),
                  const SizedBox(height: 30),
                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF7B3F1B)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Apply Promo',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutPage(
                              cartItems: cartItems,
                              subtotal: subtotal,
                              shipping: shipping,
                              total: total,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B3F1B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Proceed to Checkout',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBagItem({
    required int index,
    required String title,
    required String subtitle,
    required String size,
    required String price,
    required String imagePath,
    required int quantity,
    required String cartItemId,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: buildDecorationImage(imagePath),
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                if (size.isNotEmpty)
                  Text(size, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                const SizedBox(height: 10),
                Text(
                  price,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          // Delete + Quantity Selector
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => _firestoreService.removeFromCart(cartItemId),
                child: const Icon(Icons.close, size: 20, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.brown.shade200),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (quantity > 1) {
                          _firestoreService.updateCartItemQuantity(cartItemId, quantity - 1);
                        }
                      },
                      child: const Icon(Icons.remove, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _firestoreService.updateCartItemQuantity(cartItemId, quantity + 1),
                      child: const Icon(Icons.add, size: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
