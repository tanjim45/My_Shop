import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_shop/Homepage.dart';
import 'package:my_shop/auth_service.dart';
import 'package:my_shop/card.dart';
import 'package:my_shop/cart_controller.dart';
import 'package:my_shop/order_history_screen.dart';
import 'package:my_shop/products_data.dart';
import 'package:my_shop/profile.dart';
import 'package:my_shop/register.dart';
import 'package:my_shop/splash_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService authService = AuthService();
  final CartController cartController = CartController();

  int currentIndex = 0;

  // Login/Register  splash 
  bool showSplash = false;
  bool wasLoggedOut = false;

  @override
  void dispose() {
    cartController.dispose();
    super.dispose();
  }

  // Order hole cart clean 
  void onOrderPlaced() {
    cartController.clear();
    setState(() {
      currentIndex = 2;
    });
  }

  // Splash shesh hole Home e jabe
  void onSplashFinished() {
    setState(() {
      showSplash = false;
      currentIndex = 0;
    });
  }

  // Logout
  Future<void> logout() async {
    await authService.logout();

    cartController.clear();
    setState(() {
      currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        // Logged out
        if (user == null) {
          wasLoggedOut = true;
          showSplash = false;
          return const RegisterScreen();
        }

        //  login ba register
        if (wasLoggedOut) {
          wasLoggedOut = false;
          showSplash = true;
        }

        // Splash dekhao
        if (showSplash) {
          return SplashScreen(onFinish: onSplashFinished);
        }

        // Cart change hole ei part rebuild hobe
        return ListenableBuilder(
          listenable: cartController,
          builder: (context, _) {
            final screens = [
              HomeScreen(
                products: products,
                onAddToCart: cartController.addToCart,
              ),
              CartScreen(
                cart: cartController.cart,
                onRemove: cartController.removeFromCart,
                onIncrease: cartController.increaseQuantity,
                onDecrease: cartController.decreaseQuantity,
                total: cartController.getTotal(),
                onOrderPlaced: onOrderPlaced,
              ),
              const OrderHistoryScreen(),
              ProfileScreen(
                user: user,
                onLogout: logout,
              ),
            ];

            return Scaffold(
              body: screens[currentIndex],
              bottomNavigationBar: NavigationBar(
                selectedIndex: currentIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.shopping_cart_outlined),
                    selectedIcon: Icon(Icons.shopping_cart),
                    label: 'Cart',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.receipt_long_outlined),
                    selectedIcon: Icon(Icons.receipt_long),
                    label: 'Orders',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}