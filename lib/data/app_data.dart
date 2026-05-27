import 'package:flutter/material.dart';

class Product {
  final String id;
  final String title;
  final String subtitle;
  final double price;
  final String imageUrl;
  final String category;
  final List<String> sizes;
  final List<int> colors;
  final String description;
  final List<String> images;

  Product({
    required this.id,
    required this.title,
    this.subtitle = '',
    required this.price,
    required this.imageUrl,
    required this.category,
    this.sizes = const [],
    this.colors = const [],
    this.description = '',
    this.images = const [],
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'price': price,
    'imageUrl': imageUrl,
    'category': category,
    'sizes': sizes,
    'colors': colors,
    'description': description,
    'images': images,
  };

  factory Product.fromMap(Map<String, dynamic> map, String docId) {
    return Product(
      id: docId,
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      sizes: List<String>.from(map['sizes'] ?? []),
      colors: List<int>.from(map['colors'] ?? []),
      description: map['description'] ?? '',
      images: List<String>.from(map['images'] ?? []),
    );
  }
}

class CartItem {
  final String id;
  final String productId;
  final String title;
  final String subtitle;
  final String size;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.title,
    this.subtitle = '',
    this.size = '',
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'productId': productId,
    'title': title,
    'subtitle': subtitle,
    'size': size,
    'price': price,
    'imageUrl': imageUrl,
    'quantity': quantity,
  };

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      size: map['size'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      quantity: map['quantity'] ?? 1,
    );
  }
}

class CategoryItem {
  final String name;
  final String imageUrl;

  const CategoryItem({required this.name, required this.imageUrl});
}

class OrderItem {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double shipping;
  final double total;
  final String address;
  final String paymentMethod;
  final String status;
  final DateTime date;

  OrderItem({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.address,
    required this.paymentMethod,
    this.status = 'Pending',
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'items': items.map((e) => e.toMap()).toList(),
    'subtotal': subtotal,
    'shipping': shipping,
    'total': total,
    'address': address,
    'paymentMethod': paymentMethod,
    'status': status,
    'date': date.toIso8601String(),
  };
}

// ---------- CATEGORIES ----------
const List<CategoryItem> dummyCategories = [
  CategoryItem(name: 'Dresses', imageUrl: 'assets/images/home/Image 2.jpeg'),
  CategoryItem(name: 'Bags', imageUrl: 'assets/images/home/WhatsApp Image 2026-04-12 at 9.58.24 PM.jpeg'),
  CategoryItem(name: 'Accessories', imageUrl: 'assets/images/home/Image 6.jpeg'),
  CategoryItem(name: 'Shoes', imageUrl: 'assets/images/home/Image 5.jpeg'),
];

// ---------- PRODUCTS ----------
final List<Product> dummyProducts = [
  Product(
    id: 'p1',
    title: 'Smart Elegance Formal Set for Work',
    price: 799,
    imageUrl: 'assets/images/product listing/Image 9.jpeg',
    category: 'Dresses',
  ),
  Product(
    id: 'p2',
    title: 'White High Neck Top and Pencil Pant',
    price: 699,
    imageUrl: 'assets/images/product listing/Image 15.jpeg',
    category: 'Dresses',
  ),
  Product(
    id: 'p3',
    title: 'Modern Muse Cross Neck Work Wear',
    price: 850,
    imageUrl: 'assets/images/product listing/Image 2.jpeg',
    category: 'Dresses',
  ),
  Product(
    id: 'p4',
    title: 'Classic Luxe Pencil Casual Wear',
    price: 520,
    imageUrl: 'assets/images/product listing/Image 14.jpeg',
    category: 'Dresses',
  ),
  Product(
    id: 'p5',
    title: 'Modern Muse Work Wear',
    subtitle: 'Cross Neck Long Sleeve',
    price: 999,
    imageUrl: 'assets/images/product details/Image 24.jpeg',
    category: 'Dresses',
    sizes: ['XL', 'L', 'M', 'S'],
    colors: [0xFFA67C52, 0xFFF5E6DA, 0xFF79827B],
    description:
        'The Modern Muse Work Wear Pant and Top Set is a sleek and elegant office outfit designed for a polished professional look. With its tailored fit and minimalistic style, it offers both comfort and confidence for all day wear.',
    images: [
      'assets/images/product details/Image 24.jpeg',
      'assets/images/product details/Image 25.jpeg',
      'assets/images/product details/Image 14.jpeg',
    ],
  ),
  Product(
    id: 'p6',
    title: 'Breeze Stud Earrings - Gold',
    price: 90,
    imageUrl: 'assets/images/home/Image 8.jpeg',
    category: 'Accessories',
  ),
  Product(
    id: 'p7',
    title: 'Slingback Flats with Crystel Buckle',
    price: 170,
    imageUrl: 'assets/images/home/Image 3.jpeg',
    category: 'Shoes',
  ),
  Product(
    id: 'p8',
    title: 'Urban Chic Slide Mules',
    subtitle: 'Casual - White',
    price: 799,
    imageUrl: 'assets/images/bag/Image 20.jpeg',
    category: 'Shoes',
  ),
  Product(
    id: 'p9',
    title: 'Van Cleef Bracelet',
    subtitle: 'Black - Gold',
    price: 599,
    imageUrl: 'assets/images/bag/Image 17.jpeg',
    category: 'Accessories',
  ),
  Product(
    id: 'p10',
    title: 'Structured Tote Bag',
    subtitle: 'Camel - Leather',
    price: 449,
    imageUrl: 'assets/images/home/WhatsApp Image 2026-04-12 at 9.58.24 PM.jpeg',
    category: 'Bags',
  ),
  Product(
    id: 'p11',
    title: 'Mini Crossbody Chain Bag',
    subtitle: 'Black - Gold Chain',
    price: 320,
    imageUrl: 'assets/images/home/WhatsApp Image 2026-04-12 at 9.58.24 PM.jpeg',
    category: 'Bags',
  ),
];

// ---------- FEATURED PRODUCTS (IDs) ----------
const List<String> featuredProductIds = ['p6', 'p7'];

// ---------- IMAGE HELPER ----------
Widget buildImage(String? imageUrl, {BoxFit fit = BoxFit.cover, double? height, double? width}) {
  if (imageUrl == null || imageUrl.isEmpty) {
    return Container(color: Colors.grey[300], height: height, width: width);
  }
  if (imageUrl.startsWith('assets/')) {
    return Image.asset(imageUrl, fit: fit, height: height, width: width);
  }
  return Image.network(
    imageUrl,
    fit: fit,
    height: height,
    width: width,
    errorBuilder: (_, _, _) => Container(color: Colors.grey[300], height: height, width: width),
  );
}

DecorationImage? buildDecorationImage(String? imageUrl, {BoxFit fit = BoxFit.cover}) {
  if (imageUrl == null || imageUrl.isEmpty) return null;
  if (imageUrl.startsWith('assets/')) {
    return DecorationImage(image: AssetImage(imageUrl), fit: fit);
  }
  return DecorationImage(image: NetworkImage(imageUrl), fit: fit);
}
