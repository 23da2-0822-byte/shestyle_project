import 'package:flutter/material.dart';
import 'data/app_data.dart';
import 'services/firestore_service.dart';
import 'home_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double subtotal;
  final double shipping;
  final double total;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.shipping,
    required this.total,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _firestoreService = FirestoreService();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  String selectedPayment = 'Card';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/checkout/0e237b41-58c8-49f0-a918-c49c03a3f4d7.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Checkout',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'serif',
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Spacer for centering
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        // Stepper
                        _buildStepper(),
                        const SizedBox(height: 30),
                        // Shipping Address Form
                        const Text(
                          'Shipping Address',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        _buildTextField('Full Name', controller: _nameController),
                        const SizedBox(height: 15),
                        _buildTextField('Address', controller: _addressController),
                        const SizedBox(height: 15),
                        _buildTextField('City', controller: _cityController),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(child: _buildTextField('State', controller: _stateController)),
                            const SizedBox(width: 15),
                            Expanded(child: _buildTextField('Zip', controller: _zipController)),
                          ],
                        ),
                        const SizedBox(height: 30),
                        // Payment Methods
                        const Text(
                          'Payment methods',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(child: _buildPaymentMethod('Card', Icons.credit_card)),
                            const SizedBox(width: 15),
                            Expanded(child: _buildPaymentMethod('Cash', Icons.payments_outlined)),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // Summary
                        const Text(
                          'Summary',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        _buildSummaryRow('Subtotal', '\$${widget.subtotal.toStringAsFixed(2)}'),
                        const Divider(color: Colors.white54),
                        _buildSummaryRow('Shipping', '\$${widget.shipping.toStringAsFixed(2)}'),
                        const Divider(color: Colors.white54),
                        _buildSummaryRow('Total', '\$${widget.total.toStringAsFixed(2)}', isBold: true),
                        const SizedBox(height: 30),
                        // Place Order Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (_nameController.text.trim().isEmpty ||
                                        _addressController.text.trim().isEmpty ||
                                        _cityController.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please fill in Name, Address and City'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() => _isLoading = true);

                                    final address = [
                                      _nameController.text,
                                      _addressController.text,
                                      _cityController.text,
                                      _stateController.text,
                                      _zipController.text,
                                    ].where((s) => s.isNotEmpty).join(', ');

                                    final order = OrderItem(
                                      id: '',
                                      items: widget.cartItems,
                                      subtotal: widget.subtotal,
                                      shipping: widget.shipping,
                                      total: widget.total,
                                      address: address,
                                      paymentMethod: selectedPayment,
                                    );

                                    await _firestoreService.placeOrder(order);
                                    await _firestoreService.clearCart();

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Order placed successfully!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (_) => const HomePage()),
                                        (route) => false,
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7B3F1B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Place Order',
                                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStepItem('Shipping', true, true),
        _buildStepLine(),
        _buildStepItem('Payment', false, false, isActive: true),
        _buildStepLine(),
        _buildStepItem('Review', false, false),
      ],
    );
  }

  Widget _buildStepItem(String title, bool isCompleted, bool isCheck, {bool isActive = false}) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: isActive ? Colors.brown : Colors.transparent, width: 2),
          ),
          child: Icon(
            isCheck ? Icons.check : null,
            color: Colors.black,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        if (isActive)
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 20,
            height: 3,
            color: Colors.brown,
          ),
      ],
    );
  }

  Widget _buildStepLine() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 25),
        height: 2,
        color: Colors.white54,
      ),
    );
  }

  Widget _buildTextField(String hint, {required TextEditingController controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }

  Widget _buildPaymentMethod(String title, IconData icon) {
    bool isSelected = selectedPayment == title;
    return GestureDetector(
      onTap: () => setState(() => selectedPayment = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? Colors.brown : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(height: 5),
            Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 30,
                height: 3,
                color: Colors.brown,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(color: Colors.white, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
