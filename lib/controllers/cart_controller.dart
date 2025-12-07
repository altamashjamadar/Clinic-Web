import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;
  RxInt cartCount = 0.obs;
  RxDouble totalPrice = 0.0.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  Future<void> loadCart() async {
    if (_user == null) return;
    isLoading.value = true;
    try {
      final doc = await _firestore.collection('carts').doc(_user!.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final itemsMap = data['items'] as Map<String, dynamic>? ?? {};
        
        cartItems.clear();
        cartItems.addAll(
          itemsMap.entries.map((e) => {
            'productName': e.key,
            'quantity': e.value['quantity'] ?? 1,
            'price': e.value['price'] ?? 0.0,
            'icon': e.value['icon'],
            'color': e.value['color'],
          }).toList(),
        );
        
        cartCount.value = data['totalItems'] ?? 0;
        _calculateTotalPrice();
      }
    } catch (e) {
      print('Error loading cart: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addToCart(Map<String, dynamic> product) async {
    if (_user == null) {
      Get.snackbar('Error', 'Please log in to add items to cart');
      return;
    }

    try {
      final productName = product['name'];
      final cartDoc = _firestore.collection('carts').doc(_user!.uid);

      // Check if item already exists
      final existingDoc = await cartDoc.get();
      final existingItems = existingDoc.exists 
          ? (existingDoc.data()?['items'] as Map<String, dynamic>? ?? {})
          : {};

      int currentQuantity = 0;
      if (existingItems.containsKey(productName)) {
        currentQuantity = existingItems[productName]['quantity'] ?? 1;
      }

      // Update cart
      await cartDoc.set({
        'items': {
          productName: {
            'quantity': currentQuantity + 1,
            'price': product['price'],
            'icon': product['icon'],
            'color': product['color'],
          }
        },
        'totalItems': FieldValue.increment(1),
      }, SetOptions(merge: true));

      cartCount.value++;
      await loadCart();
      
      Get.snackbar('Success', '${product['name']} added to cart',
          backgroundColor: const Color.fromARGB(255, 76, 175, 80),
          colorText: const Color.fromARGB(255, 255, 255, 255),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2));
    } catch (e) {
      Get.snackbar('Error', 'Failed to add to cart: $e');
    }
  }

  Future<void> updateQuantity(String productName, int change) async {
    if (_user == null) return;

    try {
      final cartDoc = _firestore.collection('carts').doc(_user!.uid);
      final existingDoc = await cartDoc.get();
      
      if (!existingDoc.exists) return;

      final existingItems = existingDoc.data()?['items'] as Map<String, dynamic>? ?? {};
      final currentItem = existingItems[productName];
      
      if (currentItem == null) return;

      int newQuantity = (currentItem['quantity'] ?? 1) + change;

      if (newQuantity <= 0) {
        // Remove item
        await cartDoc.update({
          'items.$productName': FieldValue.delete(),
          'totalItems': FieldValue.increment(change),
        });
      } else {
        // Update quantity
        await cartDoc.update({
          'items.$productName.quantity': newQuantity,
          'totalItems': FieldValue.increment(change),
        });
      }

      cartCount.value += change;
      await loadCart();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update quantity: $e');
    }
  }

  Future<void> removeFromCart(String productName) async {
    if (_user == null) return;

    try {
      final cartDoc = _firestore.collection('carts').doc(_user!.uid);
      final existingDoc = await cartDoc.get();
      
      if (!existingDoc.exists) return;

      final existingItems = existingDoc.data()?['items'] as Map<String, dynamic>? ?? {};
      final currentItem = existingItems[productName];
      
      if (currentItem == null) return;

      final quantity = (currentItem['quantity'] ?? 1) as int;

      await cartDoc.update({
        'items.$productName': FieldValue.delete(),
        'totalItems': FieldValue.increment(-quantity),
      });

      cartCount.value = cartCount.value - quantity;
      await loadCart();
      Get.snackbar('Removed', '$productName removed from cart');
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove from cart: $e');
    }
  }

  void _calculateTotalPrice() {
    totalPrice.value = 0;
    for (var item in cartItems) {
      totalPrice.value += (item['price'] ?? 0.0) * (item['quantity'] ?? 1);
    }
  }

  void clearCart() async {
    if (_user == null) return;
    try {
      await _firestore.collection('carts').doc(_user!.uid).delete();
      cartItems.clear();
      cartCount.value = 0;
      totalPrice.value = 0;
    } catch (e) {
      Get.snackbar('Error', 'Failed to clear cart: $e');
    }
  }
}
