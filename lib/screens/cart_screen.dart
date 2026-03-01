import 'package:clinic_web/screens/login_screen.dart';
import 'package:clinic_web/widgets/Responsive_Wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:clinic_web/screens/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _updateQuantity(BuildContext context, String productId, int delta) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final cartRef = FirebaseFirestore.instance.collection('carts').doc(user.uid);

    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final cartSnap = await tx.get(cartRef);
        if (!cartSnap.exists) throw Exception('Cart not found');

        final data = cartSnap.data() as Map<String, dynamic>? ?? <String, dynamic>{};
        final items = Map<String, dynamic>.from(data['items'] ?? <String, dynamic>{});
        final currentQty = (items[productId] ?? 0) as int;

        if (currentQty + delta <= 0) {
          items.remove(productId);
          tx.update(cartRef, {
            'items': items,
            'totalItems': FieldValue.increment(-currentQty),
          });
        } else {
          items[productId] = currentQty + delta;
          tx.update(cartRef, {
            'items': items,
            'totalItems': FieldValue.increment(delta),
          });
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(delta > 0 ? 'Quantity increased' : 'Quantity decreased'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update cart: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Your Cart', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
          centerTitle: true,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
            ),
            onPressed: () => Get.to(() => const LoginScreen()),
            child: const Text('Login to view cart',style: TextStyle(color: Colors.white),),
          ),
        ),
      );
    }

    final cartRef = FirebaseFirestore.instance.collection('carts').doc(user.uid);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Your Cart', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: ResponsiveWrapper(
        child: SafeArea(
          child: Center(
            child: StreamBuilder<DocumentSnapshot>(
              stream: cartRef.snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snap.hasData || !snap.data!.exists) {
                  return _emptyCart(context);
                }
            
                final raw = snap.data!.data();
                final data = raw != null ? Map<String, dynamic>.from(raw as Map) : <String, dynamic>{};
                final itemsMap = Map<String, dynamic>.from(data['items'] ?? <String, dynamic>{});
                if (itemsMap.isEmpty) return _emptyCart(context);
            
                final productIds = itemsMap.keys.toList();
            
                return FutureBuilder<List<DocumentSnapshot>>(
                  future: Future.wait(productIds.map((id) => FirebaseFirestore.instance.collection('products').doc(id).get())),
                  builder: (context, productsSnap) {
                    if (productsSnap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    final productDocs = productsSnap.data ?? [];
            
                    double total = 0;
                    final rows = <Widget>[];
            
                    for (var doc in productDocs) {
                      if (!doc.exists) continue;
                      final rawP = doc.data();
                      final p = rawP != null ? Map<String, dynamic>.from(rawP as Map) : <String, dynamic>{};
                      final id = doc.id;
                      final qty = (itemsMap[id] ?? 0) as int;
                      final price = (p['price'] ?? 0) is num ? (p['price'] as num).toDouble() : 0.0;
                      final subtotal = price * qty;
                      total += subtotal;
            
                      rows.add(Card(
                        color: Colors.white,
                        child: ListTile(
                          leading: (p['imageUrl'] != null && (p['imageUrl'] as String).isNotEmpty)
                              ? Image.network(p['imageUrl'], width: 56, height: 56, fit: BoxFit.cover)
                              : const Icon(Icons.image),
                          title: Text(p['name'] ?? 'Product'),
                          subtitle: Text('₹${price.toStringAsFixed(0)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 20),
                                onPressed: qty > 0 ? () => _updateQuantity(context, id, -1) : null,
                                tooltip: 'Decrease quantity',
                              ),
                              Text('$qty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add, size: 20),
                                onPressed: () => _updateQuantity(context, id, 1),
                                tooltip: 'Increase quantity',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                onPressed: () => _updateQuantity(context, id, -qty), // Set to 0 to remove
                                tooltip: 'Remove item',
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text('₹${subtotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ));
                    }
            
                    return Column(
                      children: [
                        Expanded(
                          child: ListView(padding: const EdgeInsets.all(12), children: rows),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('Total: ₹${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                                ),
                                onPressed: () => Get.to(() => const CheckoutScreen()),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Text('Proceed to Checkout', style: TextStyle(fontSize: 18, color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('Your cart is empty', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          ElevatedButton( style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue),
          ), onPressed: () => Get.back(), child: const Text('Continue Shopping',style: TextStyle(color: Colors.white),)),
        ],
      ),
    );
  }
}