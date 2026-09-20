import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_shop/order_service.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  String _formatDate(Timestamp? ts) {
    if (ts == null) return 'Just now';
    final d = ts.toDate();
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day}/${d.month}/${d.year}  $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '📦 Order History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: OrderService.ordersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orders = snapshot.data?.docs ?? [];

          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 80),
                  SizedBox(height: 15),
                  Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data();

              final items = List<Map<String, dynamic>>.from(
                (order['items'] as List)
                    .map((e) => Map<String, dynamic>.from(e)),
              );

              // Purono order e address na-o thakte pare
              final address = order['address'] as Map<String, dynamic>?;
              final status = (order['status'] ?? 'Pending').toString();

              return Card(
                child: ExpansionTile(
                  title: Text(
                    '৳${(order['total'] as num).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${_formatDate(order['createdAt'] as Timestamp?)}\n'
                    '${order['paymentMethod']}  •  $status',
                  ),
                  children: [
                    // Delivery address
                    if (address != null)
                      ListTile(
                        leading: const Icon(Icons.location_on_outlined),
                        title: Text(
                          '${address['name']}  •  ${address['phone']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${address['address']}, ${address['city']}'
                          '${(address['note'] ?? '').toString().isNotEmpty ? '\nNote: ${address['note']}' : ''}',
                        ),
                      ),
                    if (address != null) const Divider(height: 1),

                    // Items
                    ...items.map((item) {
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item['image'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            
                          ),
                        ),
                        title: Text(item['name']),
                        subtitle:
                            Text('৳${item['price']} × ${item['quantity']}'),
                        trailing: Text(
                          '৳${item['price'] * item['quantity']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}