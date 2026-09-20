import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class OrderStatus {
  static const String pending = 'Pending';
  static const String approved = 'Approved';
  static const String onTheWay = 'On The Way';
  static const String inMart = 'In Mart';
  static const String delivered = 'Delivered';

  static const List<String> all = [
    pending,
    approved,
    onTheWay,
    inMart,
    delivered,
  ];


  /// Shudhu Pending hole delete kora jabe
  static bool canDelete(String status) {
    return status.trim().toLowerCase() == pending.toLowerCase();
  }
}

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
      'status': OrderStatus.pending,
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




  // Order delete shudhu Pending hole
  static Future<void> deleteOrder(String orderId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User logged in nei');
    }

    final ref = _ordersRef(user.uid).doc(orderId);



    // Transaction delete er thik age abar status check kore
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;

      final status = (snap.data()?['status'] ?? OrderStatus.pending).toString();
      if (!OrderStatus.canDelete(status)) {
        throw Exception('Ei order ar delete kora jabe na ($status)');
      }

      tx.delete(ref);
    });
  }
}