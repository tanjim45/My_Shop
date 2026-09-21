import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_shop/delivery_address_screen.dart';

class SummaryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final VoidCallback onOrderPlaced;

  const SummaryScreen({
    super.key,
    required this.cart,
    required this.onOrderPlaced,
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  static const double deliveryCharge = 60;

  bool couponApplied = false;
  bool _checkingAddress = false; 

  final TextEditingController _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  double getSubtotal() {
    double total = 0;
    for (var product in widget.cart) {
      total += (product['price'] as num) * (product['quantity'] as num);
    }
    return total;
  }

  // Coupon apply thakle 10% discount
  double get discount => couponApplied ? getSubtotal() * 0.10 : 0;

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
      couponApplied = (code == 'SAVE10');
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
    });
  }


  // Ager order gulo theke sesh deya address ta khuje ber kora

  Future<Map<String, dynamic>?> _getLastAddress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();

    for (final doc in snap.docs) {
      final data = doc.data();
      final addr = data['address'];
      if (addr is Map) {
        return Map<String, dynamic>.from(addr);
      }
    }
    return null;
  }

  
  Future<bool?> _askUseSavedAddress(Map<String, dynamic> address) {
    final note = (address['note'] ?? '').toString();

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Use the same address?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your previous delivery address:'),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${address['name']}  •  ${address['phone']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('${address['address']}, ${address['city']}'),
                  if (note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Note: $note'),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No, new address'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Future<void> _continueToAddress() async {
    if (_checkingAddress) return;

    setState(() => _checkingAddress = true);

    Map<String, dynamic>? lastAddress;
    try {
      lastAddress = await _getLastAddress();
    } catch (_) {
      // Error hole net na thakle etc normal address screen e jabe
      lastAddress = null;
    }

    if (!mounted) return;
    setState(() => _checkingAddress = false);

    // Ager address nai  sorasori address screen
    if (lastAddress == null) {
      _openAddressScreen();
      return;
    }

    final useSaved = await _askUseSavedAddress(lastAddress);
    if (!mounted) return;

    if (useSaved == true) {
      //  ager address diye auto continue
      _openAddressScreen(savedAddress: lastAddress);
    } else {
      //  notun address dite hobe
      _openAddressScreen();
    }
  }

  void _openAddressScreen({Map<String, dynamic>? savedAddress}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddressScreen(
          cart: widget.cart,
          total: getGrandTotal(),
          onOrderPlaced: widget.onOrderPlaced,
          savedAddress: savedAddress, 
        ),
      ),
    );
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
                      textCapitalization: TextCapitalization.characters,
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

            // Discount / Delivery / Total Summary
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
                      const Text('Delivery Charge'),
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
                  onPressed: (widget.cart.isEmpty || _checkingAddress)
                      ? null
                      : _continueToAddress,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: _checkingAddress
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Continue to Delivery Details',
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