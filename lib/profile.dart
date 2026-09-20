import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_shop/order_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  final User user;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '👤 Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 45,
              child: Icon(Icons.person, size: 50),
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: Text(
              user.displayName ?? 'No name',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              user.email ?? '',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 30),
          const Divider(),

          // Order History section
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text(
              'Order History',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OrderHistoryScreen(), // FIXED
                ),
              );
            },
          ),

          const Divider(),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
              label: const Padding(
                padding: EdgeInsets.all(15),
                child: Text('Logout', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}