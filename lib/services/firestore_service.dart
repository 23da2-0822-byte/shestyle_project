import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/app_data.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // ---------- PRODUCTS ----------
  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<List<Product>> getProductsOnce() async {
    final snapshot = await _firestore.collection('products').get();
    return snapshot.docs.map((doc) {
      return Product.fromMap(doc.data(), doc.id);
    }).toList();
  }

  Stream<List<Product>> getProductsByCategory(String category) {
    return _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // ---------- CART ----------
  Stream<List<CartItem>> getCart() {
    final uid = _userId;
    if (uid == null) return const Stream.empty();
    return _firestore.collection('carts').doc(uid).collection('items').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return CartItem.fromMap(data);
      }).toList();
    });
  }

  Future<void> addToCart(CartItem item) async {
    final uid = _userId;
    if (uid == null) return;
    final cartRef = _firestore.collection('carts').doc(uid).collection('items');
    final existing = await cartRef
        .where('productId', isEqualTo: item.productId)
        .where('size', isEqualTo: item.size)
        .get();
    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;
      final currentQty = doc.data()['quantity'] ?? 0;
      await doc.reference.update({'quantity': (currentQty as int) + 1});
    } else {
      await cartRef.add(item.toMap());
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    final uid = _userId;
    if (uid == null) return;
    await _firestore.collection('carts').doc(uid).collection('items').doc(cartItemId).delete();
  }

  Future<void> updateCartItemQuantity(String cartItemId, int quantity) async {
    final uid = _userId;
    if (uid == null) return;
    await _firestore.collection('carts').doc(uid).collection('items').doc(cartItemId).update({
      'quantity': quantity,
    });
  }

  Future<void> clearCart() async {
    final uid = _userId;
    if (uid == null) return;
    final items = await _firestore.collection('carts').doc(uid).collection('items').get();
    for (final doc in items.docs) {
      await doc.reference.delete();
    }
  }

  // ---------- ORDERS ----------
  Future<void> placeOrder(OrderItem order) async {
    final uid = _userId;
    if (uid == null) return;
    await _firestore.collection('orders').doc(uid).collection('userOrders').add(order.toMap());
  }

  Stream<List<OrderItem>> getUserOrders() {
    final uid = _userId;
    if (uid == null) return const Stream.empty();
    return _firestore
        .collection('orders')
        .doc(uid)
        .collection('userOrders')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        final items = (data['items'] as List?)?.map((e) => CartItem.fromMap(e as Map<String, dynamic>)).toList() ?? [];
        return OrderItem(
          id: doc.id,
          items: items,
          subtotal: (data['subtotal'] ?? 0).toDouble(),
          shipping: (data['shipping'] ?? 0).toDouble(),
          total: (data['total'] ?? 0).toDouble(),
          address: data['address'] ?? '',
          paymentMethod: data['paymentMethod'] ?? '',
          status: data['status'] ?? 'Pending',
          date: DateTime.tryParse(data['date'] as String? ?? '') ?? DateTime.now(),
        );
      }).toList();
    });
  }

  // ---------- PROFILE ----------
  Future<void> saveUserProfile(Map<String, dynamic> profileData) async {
    final uid = _userId;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).set(profileData, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final uid = _userId;
    if (uid == null) return null;
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }
}
