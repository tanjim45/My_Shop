import 'package:flutter/material.dart';

import 'package:my_shop/summary_screen.dart'; 

class CartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cart;

  final Function(int) onRemove;
  final Function(int) onIncrease;
  final Function(int) onDecrease;

  final double total;
  final VoidCallback onOrderPlaced;

  const CartScreen({
    super.key,
    required this.cart,
    required this.onRemove,
    required this.onIncrease,
    required this.onDecrease,
    required this.total,
    required this.onOrderPlaced,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🛒 My Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: cart.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80),
                  SizedBox(height: 15),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cart.length,
                      itemBuilder: (context, index) {
                        final product = cart[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product['image'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                            title: Text(
                              product['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '৳${product['price']} × ${product['quantity']} = '
                              '৳${product['price'] * product['quantity']}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => onDecrease(index),
                                  icon: const Icon(Icons.remove),
                                ),
                                Text(
                                  '${product['quantity']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => onIncrease(index),
                                  icon: const Icon(Icons.add),
                                ),
                                IconButton(
                                  onPressed: () => onRemove(index),
                                  icon: const Icon(Icons.delete),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Subtotal
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subtotal',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '৳${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Step 1: age Order Summary
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SummaryScreen(
                                cart: cart,
                                onOrderPlaced: onOrderPlaced,
                              ),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(15),
                          child: Text(
                            'Proceed to Checkout',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
    );
  }
}