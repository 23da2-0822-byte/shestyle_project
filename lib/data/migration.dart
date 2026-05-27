import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_data.dart';

Future<void> migrateProductsToFirestore() async {
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();

  for (final product in dummyProducts) {
    final docRef = firestore.collection('products').doc(product.id);
    batch.set(docRef, product.toMap());
  }

  await batch.commit();
  print('Migration complete');
}
