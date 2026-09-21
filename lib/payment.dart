import 'package:flutter/material.dart';
import 'package:my_shop/order_service.dart';

class PaymentScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final double total;
  final Map<String, dynamic> address;
  final VoidCallback onOrderPlaced;

  const PaymentScreen({
    super.key,
    required this.cart,
    required this.total,
    required this.address,
    required this.onOrderPlaced,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPayment = 'Cash on Delivery';
  bool isLoading = false;

  Future<void> _placeOrder() async {
    setState(() => isLoading = true);

    try {
      //  Order  address Firestore e save
      await OrderService.saveOrder(
        cart: widget.cart,
        total: widget.total,
        paymentMethod: selectedPayment,
        address: widget.address,
      );

      //  Cart clear  Orders tab e jao 
      widget.onOrderPlaced();

      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order placed using $selectedPayment')),
      );

      // Address Payment page bondho kore Order History te fire jao
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final address = widget.address;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '💳 Payment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery address
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(
                    '${address['name']}  •  ${address['phone']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${address['address']}, ${address['city']}',
                  ),
                  trailing: TextButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Change'),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text('Order Total', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 5),
              Text(
                '৳${widget.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              RadioListTile<String>(
                title: const Text('Cash on Delivery'),
                value: 'Cash on Delivery',
                groupValue: selectedPayment,
                onChanged: (value) {
                  setState(() => selectedPayment = value!);
                },
              ),
              RadioListTile<String>(
                title: const Text('Mobile Banking'),
                value: 'Mobile Banking',
                groupValue: selectedPayment,
                onChanged: (value) {
                  setState(() => selectedPayment = value!);
                },
              ),
              RadioListTile<String>(
                title: const Text('Card'),
                value: 'Card',
                groupValue: selectedPayment,
                onChanged: (value) {
                  setState(() => selectedPayment = value!);
                },
              ),
              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (widget.cart.isEmpty || isLoading)
                      ? null
                      : _placeOrder,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Place Order',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}