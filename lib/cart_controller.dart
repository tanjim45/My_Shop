import 'package:flutter/foundation.dart';

class CartController extends ChangeNotifier {
  final List<Map<String, dynamic>> cart = [];

  // Add product to cart
  void addToCart(Map<String, dynamic> product) {
    final existingIndex = cart.indexWhere(
      (item) => item['name'] == product['name'],
    );

    if (existingIndex != -1) {
      cart[existingIndex]['quantity']++;
    } else {
      cart.add({
        'name': product['name'],
        'price': product['price'],
        'quantity': 1,
        'image': product['image'],
      });
    }

    notifyListeners();
  }

  // Remove product
  void removeFromCart(int index) {
    cart.removeAt(index);
    notifyListeners();
  }

  // Increase quantity
  void increaseQuantity(int index) {
    cart[index]['quantity']++;
    notifyListeners();
  }

  // Decrease quantity
  void decreaseQuantity(int index) {
    if (cart[index]['quantity'] > 1) {
      cart[index]['quantity']--;
      notifyListeners();
    }
  }

  // Calculate total
  double getTotal() {
    double total = 0;

    for (var product in cart) {
      total += product['price'] * product['quantity'];
    }

    return total;
  }

  // Cart clear
  void clear() {
    cart.clear();
    notifyListeners();
  }
}