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

  // Status onujayi color
  Color _statusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'on the way':
        return Colors.purple;
      case 'in mart':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Status onujayi icon
  IconData _statusIcon(String status) {
    switch (status.trim().toLowerCase()) {
      case 'pending':
        return Icons.hourglass_top;
      case 'approved':
        return Icons.check_circle_outline;
      case 'on the way':
        return Icons.local_shipping_outlined;
      case 'in mart':
        return Icons.storefront_outlined;
      case 'delivered':
        return Icons.done_all;
      default:
        return Icons.info_outline;
    }
  }

  Widget _statusChip(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(status), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String orderId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are You Wanted to Delect Your Order?'),
        content: const Text('Once this order is deleted, it cannot be recovered..'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await OrderService.deleteOrder(orderId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order delete hoyeche')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
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
              final orderId = orders[index].id;
              final order = orders[index].data();

              final items = List<Map<String, dynamic>>.from(
                (order['items'] as List)
                    .map((e) => Map<String, dynamic>.from(e)),
              );

              // Purono order e address nao thakte pare
              final address = order['address'] as Map<String, dynamic>?;

              // Purono order e status na thakle Pending dhorbo
              final status = (order['status'] ?? OrderStatus.pending).toString();
              final canDelete = OrderStatus.canDelete(status);

              return Card(
                child: Column(
                  children: [
                    ExpansionTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '৳${(order['total'] as num).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _statusChip(status),
                        ],
                      ),
                      subtitle: Text(
                        '${_formatDate(order['createdAt'] as Timestamp?)}\n'
                        '${order['paymentMethod']}',
                      ),
                      children: [
                        // Delivery address
                        if (address != null)
                          ListTile(
                            leading: const Icon(Icons.location_on_outlined),
                            title: Text(
                              '${address['name']}  •  ${address['phone']}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
                                errorBuilder: (_, __, ___) => const SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                            title: Text(item['name']),
                            subtitle: Text(
                                '৳${item['price']} × ${item['quantity']}'),
                            trailing: Text(
                              '৳${item['price'] * item['quantity']}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        }),
                      ],
                    ),

                    // Delete button 
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              canDelete
                                  ? 'Pending items can still be deleted.'
                                  : 'Sorry, this order cannot be deleted.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),

                          
                          // onPressed null hole button automatic unclickable
                          OutlinedButton.icon(
                            onPressed: canDelete
                                ? () => _confirmDelete(context, orderId)
                                : null,
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Delete'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              disabledForegroundColor: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
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