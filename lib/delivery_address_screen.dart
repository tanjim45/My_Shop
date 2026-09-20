import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_shop/payment.dart';

class AddressScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final double total;
  final VoidCallback onOrderPlaced;

  const AddressScreen({
    super.key,
    required this.cart,
    required this.total,
    required this.onOrderPlaced,
  });

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();

  // Registration er nam thakle auto boshe jabe
  final nameController = TextEditingController(
    text: FirebaseAuth.instance.currentUser?.displayName ?? '',
  );
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final noteController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;

    final address = {
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'address': addressController.text.trim(),
      'city': cityController.text.trim(),
      'note': noteController.text.trim(),
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          cart: widget.cart,
          total: widget.total,
          address: address,
          onOrderPlaced: widget.onOrderPlaced,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ' Delivery Address',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name din';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          hintText: '01XXXXXXXXX',
                          prefixIcon: Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final phone = value?.trim() ?? '';
                          if (phone.isEmpty) {
                            return 'Phone number din';
                          }
                          if (!RegExp(r'^01[3-9]\d{8}$').hasMatch(phone)) {
                            return 'please Enter 11 digit PhoneNumber (01XXXXXXXXX)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: addressController,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Full Address',
                          hintText: 'House, Road, Area',
                          prefixIcon: Icon(Icons.home_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length < 5) {
                            return 'Please Enter Full Adress';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: cityController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'City / District',
                          prefixIcon: Icon(Icons.location_city_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'City / District ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: noteController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Note (optional)',
                          hintText: 'Jemon: gate er samne rekhe jaben',
                          prefixIcon: Icon(Icons.note_alt_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Total + Continue
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Order Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '৳${widget.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _continue,
                      child: const Padding(
                        padding: EdgeInsets.all(15),
                        child: Text(
                          'Continue to Payment',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}