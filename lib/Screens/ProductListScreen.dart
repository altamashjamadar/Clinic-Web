// lib/screens/product_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'login_screen.dart'; // Your login screen
import './CartScreen.dart'; // Your cart screen

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});
  @override State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filtered = [];
  int cartCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
   if (_user != null) _listenToCart();
  }
void _listenToCart() {
  _firestore.collection('carts').doc(_user!.uid).snapshots().listen((doc) {
    setState(() {
      cartCount = (doc.data()?['totalItems'] ?? 0) as int;
    });
  });
}
  Future<void> _loadProducts() async {
    final snapshot = await _firestore.collection('products').get();
    setState(() {
      products = snapshot.docs.map((d) => d.data()..['id'] = d.id).toList();
      filtered = List.from(products);
    });
  }

  Future<void> _loadCartCount() async {
    final doc = await _firestore.collection('carts').doc(_user!.uid).get();
    setState(() => cartCount = (doc.data()?['totalItems'] ?? 0) as int);
  }

  // void _addToCart(Map<String, dynamic> product) async {
  //   if (_user == null) {
  //     Get.to(() => const LoginScreen()); // Force login
  //     return;
  //   }

  //   final qty = (product['quantity'] ?? 0);
  //   if (qty <= 0) {
  //     Get.snackbar('Out of Stock', 'This product is unavailable');
  //     return;
  //   }

  //   await _firestore.collection('carts').doc(_user!.uid).set({
  //     'items.${product['id']}': FieldValue.increment(1),
  //     'totalItems': FieldValue.increment(1),
  //   }, SetOptions(merge: true));

  //   setState(() => cartCount++);
  //   Get.snackbar('Added', '${product['name']} added to cart');
  // }
  void _addToCart(Map<String, dynamic> product) async {
  if (_user == null) {
    Get.to(() => const LoginScreen());
    return;
  }

  final qty = (product['quantity'] ?? 0);
  if (qty <= 0) {
    Get.snackbar('Out of Stock', 'This product is unavailable');
    return;
  }

  await _firestore.collection('carts').doc(_user!.uid).set({
    'items.${product['id']}': FieldValue.increment(1),
    'totalItems': FieldValue.increment(1),
  }, SetOptions(merge: true));

  setState(() => cartCount++);
  Get.snackbar('Added', '${product['name']} added to cart');
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products5'),
        centerTitle:true,
        actions: [
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () => Get.to(() => const CartScreen())),
              if (cartCount > 0) Positioned(right: 8, top: 8, child: CircleAvatar(radius: 8, backgroundColor: Colors.red, child: Text('$cartCount', style: const TextStyle(fontSize: 10)))),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, i) {
          final p = filtered[i];
          final inStock = (p['quantity'] ?? 0) > 0;

          return Card(
            child: ListTile(
              leading: p['imageUrl'] != null ? Image.network(p['imageUrl'], width: 60, height: 60, fit: BoxFit.cover) : const Icon(Icons.image),
              title: Text(p['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('₹${p['price']}'),
                  Text('Stock: ${p['quantity'] ?? 0}', style: TextStyle(color: inStock ? Colors.green : Colors.red)),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: inStock ? () => _addToCart(p) : null,
                child: Text(inStock ? 'Add' : 'Out of Stock'),
              ),
            ),
          );
        },
      ),
    );
  }
}