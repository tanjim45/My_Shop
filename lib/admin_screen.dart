import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
}

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _filter = 'All';

  String _formatDate(Timestamp? ts) {
    if (ts == null) return 'Just now';
    final d = ts.toDate();
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day}/${d.month}/${d.year}  $h:$m';
  }

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

  // Firestore er status ke dropdown er list er sathe milie nei
  String _normalize(String raw) {
    return OrderStatus.all.firstWhere(
      (s) => s.toLowerCase() == raw.trim().toLowerCase(),
      orElse: () => OrderStatus.pending,
    );
  }

  Future<void> _changeStatus(
    BuildContext context,
    DocumentReference<Map<String, dynamic>> ref,
    String newStatus,
  ) async {
    try {
      await ref.update({'status': newStatus});
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status: $newStatus')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🛠 Admin - Orders',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              children: ['All', ...OrderStatus.all].map((s) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(s),
                    selected: _filter == s,
                    onSelected: (_) => setState(() => _filter = s),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              
              stream: FirebaseFirestore.instance
                  .collectionGroup('orders')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                var docs = snapshot.data?.docs.toList() ?? [];

                // Notun order age
                docs.sort((a, b) {
                  final ta = a.data()['createdAt'] as Timestamp?;
                  final tb = b.data()['createdAt'] as Timestamp?;
                  if (ta == null && tb == null) return 0;
                  if (ta == null) return -1;
                  if (tb == null) return 1;
                  return tb.compareTo(ta);
                });

                // Filter
                if (_filter != 'All') {
                  docs = docs
                      .where((d) =>
                          _normalize((d.data()['status'] ?? '').toString()) ==
                          _filter)
                      .toList();
                }

                if (docs.isEmpty) {
                  return const Center(child: Text('Kono order nei'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final order = doc.data();

                    final status =
                        _normalize((order['status'] ?? '').toString());
                    final address = order['address'] as Map<String, dynamic>?;
                    final items = List<Map<String, dynamic>>.from(
                      ((order['items'] ?? []) as List)
                          .map((e) => Map<String, dynamic>.from(e)),
                    );

                    // find UID
                    final uid = doc.reference.parent.parent?.id ?? '';
                    final shortId =
                        doc.id.length > 6 ? doc.id.substring(0, 6) : doc.id;

                    return Card(
                      child: Column(
                        children: [
                          ExpansionTile(
                            title: Text(
                              '৳${((order['total'] ?? 0) as num).toStringAsFixed(2)}'
                              '   #$shortId',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${address?['name'] ?? 'No name'}  •  ${address?['phone'] ?? ''}\n'
                              '${_formatDate(order['createdAt'] as Timestamp?)}  •  ${order['paymentMethod'] ?? ''}',
                            ),
                            children: [
                              if (address != null)
                                ListTile(
                                  leading:
                                      const Icon(Icons.location_on_outlined),
                                  title: Text(
                                      '${address['address']}, ${address['city']}'),
                                  subtitle: Text(
                                    (address['note'] ?? '').toString().isEmpty
                                        ? 'User: $uid'
                                        : 'Note: ${address['note']}\nUser: $uid',
                                  ),
                                ),
                              ...items.map(
                                (item) => ListTile(
                                  dense: true,
                                  title: Text('${item['name']}'),
                                  subtitle: Text(
                                      '৳${item['price']} × ${item['quantity']}'),
                                  trailing: Text(
                                    '৳${item['price'] * item['quantity']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 1),

                          // Status change dropdown
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            child: Row(
                              children: [
                                const Text('Status:  ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Expanded(
                                  child: DropdownButton<String>(
                                    value: status,
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    items: OrderStatus.all.map((s) {
                                      return DropdownMenuItem(
                                        value: s,
                                        child: Text(
                                          s,
                                          style: TextStyle(
                                            color: _statusColor(s),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (v) {
                                      if (v == null || v == status) return;
                                      _changeStatus(
                                          context, doc.reference, v);
                                    },
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
          ),
        ],
      ),
    );
  }
}