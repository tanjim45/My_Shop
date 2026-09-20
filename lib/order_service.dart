import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _ordersRef(String uid) {
    return _db.collection('users').doc(uid).collection('orders');
  }

  // Order save
  static Future<void> saveOrder({
    required List<Map<String, dynamic>> cart,
    required double total,
    required String paymentMethod,
    required Map<String, dynamic> address,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User logged in nei');
    }

    await _ordersRef(user.uid).add({
      'items': cart
          .map(
            (item) => {
              'name': item['name'],
              'price': item['price'],
              'quantity': item['quantity'],
              'image': item['image'],
            },
          )
          .toList(),
      'total': total,
      'paymentMethod': paymentMethod,
      'address': address,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Order history (notun order age)
  static Stream<QuerySnapshot<Map<String, dynamic>>> ordersStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _ordersRef(user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}