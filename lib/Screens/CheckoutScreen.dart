// lib/screens/checkout_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rns_herbals_app/Screens/home_page.dart';
import 'package:rns_herbals_app/Screens/login_screen.dart';
// lib/screens/checkout_screen.dart
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;
  bool _loading = false;

  Future<void> _placeOrder() async {
    if (_user == null) {
      Get.to(() => const LoginScreen());
      return;
    }

    setState(() => _loading = true);
    try {
      final cartSnap = await _firestore.collection('carts').doc(_user!.uid).get();
      final items = (cartSnap.data()?['items'] as Map<String, dynamic>?) ?? {};

      // Check stock
      for (var entry in items.entries) {
        final prodSnap = await _firestore.collection('products').doc(entry.key).get();
        final stock = prodSnap.data()?['quantity'] ?? 0;
        if (stock < (entry.value as int)) {
          Get.snackbar('Error', 'Not enough stock for ${prodSnap['name']}');
          return;
        }
      }

      // Reduce stock
      final batch = _firestore.batch();
      for (var entry in items.entries) {
        final prodRef = _firestore.collection('products').doc(entry.key);
        batch.update(prodRef, {'quantity': FieldValue.increment(-(entry.value as int))});
      }

      // Create order
      final orderRef = _firestore.collection('orders').doc();
      batch.set(orderRef, {
        'userId': _user!.uid,
        'items': items.entries.map((e) => {'productId': e.key, 'quantity': e.value}).toList(),
        'totalPrice': 0, // Calculate from items
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      await _firestore.collection('carts').doc(_user!.uid).delete();

      Get.snackbar('Success', 'Order placed!');
      Get.offAll(() => const HomePage());
    } catch (e) {
      Get.snackbar('Error', 'Failed: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Center(
        child: ElevatedButton(
          onPressed: _loading ? null : _placeOrder,
          child: _loading ? const CircularProgressIndicator() : const Text('Place Order'),
        ),
      ),
    );
  }
}