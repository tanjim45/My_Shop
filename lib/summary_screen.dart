import 'package:flutter/material.dart';
import 'package:my_shop/payment.dart';

class SummaryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final VoidCallback onOrderPlaced; // NEW

  const SummaryScreen({
    super.key,
    required this.cart,
    required this.onOrderPlaced, // NEW
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  double discount = 0;
  double deliveryCharge = 60;

  bool couponApplied = false;

  final TextEditingController _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  double getSubtotal() {
    double total = 0;
    for (var product in widget.cart) {
      total += product['price'] * product['quantity'];
    }
    return total;
  }

  double getGrandTotal() {
    return getSubtotal() - discount + deliveryCharge;
  }

  void applyCoupon() {
    final code = _couponController.text.trim().toUpperCase();

    if (widget.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty, add products first')),
      );
      return;
    }

    setState(() {
      if (code == 'SAVE10') {
        discount = getSubtotal() * 0.10;
        couponApplied = true;
      } else {
        discount = 0;
        couponApplied = false;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          couponApplied
              ? 'Coupon applied! 10% discount'
              : 'Invalid coupon code',
        ),
      ),
    );
  }

  void clearCoupon() {
    setState(() {
      _couponController.clear();
      couponApplied = false;
      discount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🧾 Order Summary',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.cart.length,
                itemBuilder: (context, index) {
                  final product = widget.cart[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: ListTile(
                      title: Text(product['name']),
                      subtitle: Text(
                        '৳${product['price']} × ${product['quantity']} = '
                        '৳${product['price'] * product['quantity']}',
                      ),
                    ),
                  );
                },
              ),
            ),

            // Coupon Section
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _couponController,
                      decoration: InputDecoration(
                        labelText: 'Coupon Code',
                        hintText: 'Enter coupon code',
                        border: const OutlineInputBorder(),
                        suffixIcon: couponApplied
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: clearCoupon,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: applyCoupon,
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ),

            if (couponApplied)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'SAVE10 applied - 10% discount added successfully',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Discount / Total Summary
            Container(
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal'),
                      Text('৳${getSubtotal().toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Discount'),
                      Text('- ৳${discount.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Delivery'),
                      Text('৳${deliveryCharge.toStringAsFixed(2)}'),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Grand Total',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '৳${getGrandTotal().toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.cart.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentScreen(
                                cart: widget.cart,
                                total: getGrandTotal(),
                                onOrderPlaced: widget.onOrderPlaced, address: {}, // NEW
                              ),
                            ),
                          );
                        },
                  child: const Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      'Continue to Payment',
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