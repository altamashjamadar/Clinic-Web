// // // lib/screens/cart_screen.dart
// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:get/get.dart';
// // import 'package:rns_herbals_app/Screens/login_screen.dart';

// // class CartScreen extends StatefulWidget {
// //   const CartScreen({super.key});
// //   @override State<CartScreen> createState() => _CartScreenState();
// // }

// // class _CartScreenState extends State<CartScreen> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   final User? _user = FirebaseAuth.instance.currentUser;

// //   List<Map<String, dynamic>> cartItems = [];
// //   int totalItems = 0;
// //   double totalPrice = 0.0;
// //   bool _isLoading = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadCartWithProducts();
// //   }
// //   Future<void> _checkout() async {
// //   if (_user == null) {
// //     Get.to(() => const LoginScreen());
// //     return;
// //   }

// //   final orderId = DateTime.now().millisecondsSinceEpoch.toString();
// //   final orderData = {
// //     'orderId': orderId,
// //     'userId': _user!.uid,
// //     'userName': _user!.displayName ?? 'User',
// //     'userPhone': '', // You can add phone in profile
// //     'userEmail': _user!.email,
// //     'items': cartItems.map((i) => {
// //       'id': i['id'],
// //       'name': i['name'],
// //       'price': i['price'],
// //       'quantity': i['quantity'],
// //       'imageUrl': i['imageUrl'],
// //     }).toList(),
// //     'totalPrice': totalPrice,
// //     'address': 'User Address Here', // Get from profile
// //     'status': 'pending',
// //     'createdAt': FieldValue.serverTimestamp(),
// //   };

// //   try {
// //     // 1. Save Order
// //     await _firestore.collection('orders').doc(orderId).set(orderData);

// //     // 2. Clear Cart
// //     await _firestore.collection('carts').doc(_user!.uid).delete();

// //     Get.offAllNamed('/order-success');
// //     // Get.snackbar('Success', 'Order placed! #$orderId', backgroundColor: Colors.green, colorText: Colors.white);
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content:  Text('Order placed! #$orderId'),
// //           backgroundColor: Colors.green,
// //           behavior: SnackBarBehavior.floating,
// //           duration: const Duration(seconds: 5)
// //         ),
// //       );
// //   } catch (e) {
// //     // Get.snackbar('Error', 'Checkout failed: $e');
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content:  Text('Checkout failed: $e')),
// //       );
// //   }
// // }
// //   Future<void> _loadCartWithProducts() async {
// //     if (_user == null) {
// //       setState(() => _isLoading = false);
// //       return;
// //     }

// //     try {
// //       final cartDoc = await _firestore.collection('carts').doc(_user!.uid).get();
// //       if (!cartDoc.exists) {
// //         setState(() => _isLoading = false);
// //         return;
// //       }

// //       final data = cartDoc.data()!;
// //       final itemsMap = Map<String, dynamic>.from(data['items'] ?? {});

// //       totalItems = data['totalItems'] ?? 0;

// //       final List<Map<String, dynamic>> loadedItems = [];

// //       // Fetch product details
// //       for (var entry in itemsMap.entries) {
// //         final productId = entry.key;
// //         final quantity = entry.value as int;

// //         final prodSnap = await _firestore.collection('products').doc(productId).get();
// //         if (prodSnap.exists) {
// //           final prodData = prodSnap.data()!;
// //           loadedItems.add({
// //             'id': productId,
// //             'name': prodData['name'] ?? 'Unknown',
// //             'price': (prodData['price'] ?? 0).toDouble(),
// //             'imageUrl': prodData['imageUrl'],
// //             'quantity': quantity,
// //           });
// //           totalPrice += (prodData['price'] ?? 0) * quantity;
// //         }
// //       }

// //       setState(() {
// //         cartItems = loadedItems;
// //         _isLoading = false;
// //       });
// //     } catch (e) {
// //       // Get.snackbar('Error', 'Failed to load cart: $e');
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content:  Text('Failed to load cart: $e')),
// //       );
// //       setState(() => _isLoading = false);
// //     }
// //   }

// //   Future<void> _updateQuantity(String id, int change) async {
// //     final item = cartItems.firstWhere((e) => e['id'] == id);
// //     final newQty = item['quantity'] + change;

// //     if (newQty <= 0) {
// //       await _firestore.collection('carts').doc(_user!.uid).update({
// //         'items.$id': FieldValue.delete(),
// //         'totalItems': FieldValue.increment(change),
// //       });
// //     } else {
// //       await _firestore.collection('carts').doc(_user!.uid).update({
// //         'items.$id': newQty,
// //         'totalItems': FieldValue.increment(change),
// //       });
// //     }

// //     setState(() {
// //       totalPrice += item['price'] * change;
// //       if (newQty <= 0) {
// //         cartItems.removeWhere((e) => e['id'] == id);
// //       } else {
// //         item['quantity'] = newQty;
// //       }
// //       totalItems += change;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.grey[50],
// //       appBar: AppBar(
// //         title: const Text('My Cart'),
// //         backgroundColor: Colors.blue,
// //         foregroundColor: Colors.white,
// //       ),
// //       body: _isLoading
// //           ? const Center(child: CircularProgressIndicator())
// //           : cartItems.isEmpty
// //               ? Center(
// //                   child: Column(
// //                     mainAxisSize: MainAxisSize.min,
// //                     children: [
// //                       Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
// //                       const SizedBox(height: 16),
// //                       const Text('Your cart is empty', style: TextStyle(fontSize: 18)),
// //                       const SizedBox(height: 8),
// //                       ElevatedButton(
// //                         onPressed: () => Get.back(),
// //                         child: const Text('Continue Shopping'),
// //                       ),
// //                     ],
// //                   ),
// //                 )
// //               : Column(
// //                   children: [
// //                     Expanded(
// //                       child: ListView.builder(
// //                         padding: const EdgeInsets.all(12),
// //                         itemCount: cartItems.length,
// //                         itemBuilder: (context, i) {
// //                           final item = cartItems[i];
// //                           return Card(
// //                             elevation: 2,
// //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //                             child: Padding(
// //                               padding: const EdgeInsets.all(12),
// //                               child: Row(
// //                                 children: [
// //                                   // Product Image
// //                                   ClipRRect(
// //                                     borderRadius: BorderRadius.circular(8),
// //                                     child: item['imageUrl'] != null
// //                                         ? Image.network(item['imageUrl'], width: 70, height: 70, fit: BoxFit.cover)
// //                                         : Container(width: 70, height: 70, color: Colors.grey[300], child: const Icon(Icons.image)),
// //                                   ),
// //                                   const SizedBox(width: 12),

// //                                   // Product Info
// //                                   Expanded(
// //                                     child: Column(
// //                                       crossAxisAlignment: CrossAxisAlignment.start,
// //                                       children: [
// //                                         Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
// //                                         const SizedBox(height: 4),
// //                                         Text('₹${item['price']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
// //                                       ],
// //                                     ),
// //                                   ),

// //                                   // Quantity Controls
// //                                   Row(
// //                                     children: [
// //                                       IconButton(
// //                                         icon: const Icon(Icons.remove_circle_outline),
// //                                         onPressed: () => _updateQuantity(item['id'], -1),
// //                                       ),
// //                                       Text('${item['quantity']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
// //                                       IconButton(
// //                                         icon: const Icon(Icons.add_circle_outline),
// //                                         onPressed: () => _updateQuantity(item['id'], 1),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           );
// //                         },
// //                       ),
// //                     ),

// //                     // Total Summary
// //                     Container(
// //                       padding: const EdgeInsets.all(16),
// //                       decoration: BoxDecoration(
// //                         color: Colors.white,
// //                         boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10)],
// //                       ),
// //                       child: Column(
// //                         children: [
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               const Text('Total Items', style: TextStyle(fontSize: 16)),
// //                               Text('$totalItems', style: const TextStyle(fontWeight: FontWeight.bold)),
// //                             ],
// //                           ),
// //                           const SizedBox(height: 8),
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               const Text('Total Amount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //                               Text('₹${totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
// //                             ],
// //                           ),
// //                           const SizedBox(height: 16),
                        
// // ElevatedButton(
// //   style: ElevatedButton.styleFrom(
// //     backgroundColor: Colors.blue,
// //     padding: const EdgeInsets.symmetric(vertical: 16),
// //   ),
// //   onPressed: cartItems.isEmpty ? null : _checkout,
// //   child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 18, color: Colors.white)),
// // ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //     );
// //   }
// // }

// // lib/screens/CartScreen.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';
// import 'package:rns_herbals_app/Screens/login_screen.dart';

// class CartScreen extends StatelessWidget {
//   const CartScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Your Cart')),
//         body: Center(
//           child: ElevatedButton(
//             onPressed: () => Get.to(() => const LoginScreen()),
//             child: const Text('Login to view cart'),
//           ),
//         ),
//       );
//     }

//     final cartRef = FirebaseFirestore.instance.collection('carts').doc(user.uid);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Your Cart')),
//       body: StreamBuilder<DocumentSnapshot>(
//         stream: cartRef.snapshots(),
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
//           if (!snap.hasData || !snap.data!.exists) {
//             return _emptyCart(context);
//           }

//           // safe conversion of snapshot data to Map<String, dynamic>
//           final raw = snap.data!.data();
//           final data = raw != null ? Map<String, dynamic>.from(raw as Map) : <String, dynamic>{};
//           final itemsMap = Map<String, dynamic>.from(data['items'] ?? <String, dynamic>{});
//           if (itemsMap.isEmpty) return _emptyCart(context);

//           final productIds = itemsMap.keys.toList();

//           return FutureBuilder<List<DocumentSnapshot>>(
//             future: Future.wait(productIds.map((id) => FirebaseFirestore.instance.collection('products').doc(id).get())),
//             builder: (context, productsSnap) {
//               if (productsSnap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
//               final productDocs = productsSnap.data ?? [];

//               double total = 0;
//               final rows = <Widget>[];

//               for (var doc in productDocs) {
//                 if (!doc.exists) continue;
//                 final rawP = doc.data();
//                 final p = rawP != null ? Map<String, dynamic>.from(rawP as Map) : <String, dynamic>{};
//                 final id = doc.id;
//                 final qty = (itemsMap[id] ?? 0) as int;
//                 final price = (p['price'] ?? 0) is num ? (p['price'] as num).toDouble() : 0.0;
//                 final subtotal = price * qty;
//                 total += subtotal;

//                 rows.add(Card(
//                   child: ListTile(
//                     leading: (p['imageUrl'] != null && (p['imageUrl'] as String).isNotEmpty)
//                         ? Image.network(p['imageUrl'], width: 56, height: 56, fit: BoxFit.cover)
//                         : const Icon(Icons.image),
//                     title: Text(p['name'] ?? 'Product'),
//                     subtitle: Text('₹${price.toStringAsFixed(0)}  •  x$qty'),
//                     trailing: Text('₹${subtotal.toStringAsFixed(0)}'),
//                   ),
//                 ));
//               }

//               return Column(
//                 children: [
//                   Expanded(
//                     child: ListView(padding: const EdgeInsets.all(12), children: rows),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Text('Total: ₹${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 12),
//                         ElevatedButton(
//                           onPressed: () {
//                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checkout not implemented')));
//                           },
//                           child: const Padding(
//                             padding: EdgeInsets.symmetric(vertical: 14),
//                             child: Text('Proceed to Checkout'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _emptyCart(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
//           const SizedBox(height: 12),
//           const Text('Your cart is empty', style: TextStyle(fontSize: 18)),
//           const SizedBox(height: 12),
//           ElevatedButton(onPressed: () => Get.back(), child: const Text('Continue Shopping')),
//         ],
//       ),
//     );
//   }
// }


// // lib/screens/CartScreen.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';
// import 'package:rns_herbals_app/Screens/CheckoutScreen.dart';
// import 'package:rns_herbals_app/Screens/login_screen.dart';
// // import 'checkout_screen.dart'; // Import CheckoutScreen (ensure path is correct)

// class CartScreen extends StatelessWidget {
//   const CartScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       return Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(title: const Text('Your Cart3',style: TextStyle(color: Colors.white),
//         ),backgroundColor: Colors.blue,
//         centerTitle: true,
//         foregroundColor: Colors.white,
//         ),
//         body: Center(
//           child: ElevatedButton(
//             onPressed: () => Get.to(() => const LoginScreen()),
//             child: const Text('Login to view cart'),
//           ),
//         ),
//       );
//     }

//     final cartRef = FirebaseFirestore.instance.collection('carts').doc(user.uid);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Your Cart',style: TextStyle(color: Colors.white),
//         ),backgroundColor: Colors.blue,
//         centerTitle: true,
//         foregroundColor: Colors.white,
//       ),
//       body: StreamBuilder<DocumentSnapshot>(
//         stream: cartRef.snapshots(),
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
//           if (!snap.hasData || !snap.data!.exists) {
//             return _emptyCart(context);
//           }

//           // safe conversion of snapshot data to Map<String, dynamic>
//           final raw = snap.data!.data();
//           final data = raw != null ? Map<String, dynamic>.from(raw as Map) : <String, dynamic>{};
//           final itemsMap = Map<String, dynamic>.from(data['items'] ?? <String, dynamic>{});
//           if (itemsMap.isEmpty) return _emptyCart(context);

//           final productIds = itemsMap.keys.toList();

//           return FutureBuilder<List<DocumentSnapshot>>(
//             future: Future.wait(productIds.map((id) => FirebaseFirestore.instance.collection('products').doc(id).get())),
//             builder: (context, productsSnap) {
//               if (productsSnap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
//               final productDocs = productsSnap.data ?? [];

//               double total = 0;
//               final rows = <Widget>[];

//               for (var doc in productDocs) {
//                 if (!doc.exists) continue;
//                 final rawP = doc.data();
//                 final p = rawP != null ? Map<String, dynamic>.from(rawP as Map) : <String, dynamic>{};
//                 final id = doc.id;
//                 final qty = (itemsMap[id] ?? 0) as int;
//                 final price = (p['price'] ?? 0) is num ? (p['price'] as num).toDouble() : 0.0;
//                 final subtotal = price * qty;
//                 total += subtotal;

//                 rows.add(Card(
//                   color: Colors.white,
//                   child: ListTile(
//                     leading: (p['imageUrl'] != null && (p['imageUrl'] as String).isNotEmpty)
//                         ? Image.network(p['imageUrl'], width: 56, height: 56, fit: BoxFit.cover)
//                         : const Icon(Icons.image),
//                     title: Text(p['name'] ?? 'Product'),
//                     subtitle: Text('₹${price.toStringAsFixed(0)}  •  x$qty'),
//                     trailing: Text('₹${subtotal.toStringAsFixed(0)}'),
//                   ),
//                 ));
//               }

//               return Column(
//                 children: [
//                   Expanded(
//                     child: ListView(padding: const EdgeInsets.all(12), children: rows),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Text('Total: ₹${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,)),
                        
//                         const SizedBox(height: 12),
//                         ElevatedButton(
//                           style: ButtonStyle(
//                             backgroundColor: MaterialStateProperty.all(Colors.blue),
//                           ),
//                           onPressed: () => Get.to(() => const CheckoutScreen()),
//                           child: const Padding(
//                             padding: EdgeInsets.symmetric(vertical: 14),
//                             child: Text('Proceed to Checkout',style: TextStyle(fontSize: 18, color: Colors.white),),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _emptyCart(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
//           const SizedBox(height: 12),
//           const Text('Your cart is empty', style: TextStyle(fontSize: 18)),
//           const SizedBox(height: 12),
//           ElevatedButton(onPressed: () => Get.back(), child: const Text('Continue Shopping')),
//         ],
//       ),
//     );
//   }
// }

// lib/screens/CartScreen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:rns_herbals_app/Screens/CheckoutScreen.dart';
import 'package:rns_herbals_app/Screens/login_screen.dart';

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
          // Remove item if qty <= 0
          items.remove(productId);
          tx.update(cartRef, {
            'items': items,
            'totalItems': FieldValue.increment(-currentQty),
          });
        } else {
          // Update qty
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
          title: const Text('Your Cart3', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
          centerTitle: true,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () => Get.to(() => const LoginScreen()),
            child: const Text('Login to view cart'),
          ),
        ),
      );
    }

    final cartRef = FirebaseFirestore.instance.collection('carts').doc(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: cartRef.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snap.hasData || !snap.data!.exists) {
            return _emptyCart(context);
          }

          // safe conversion of snapshot data to Map<String, dynamic>
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
                        // Quantity controls
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
                        // Remove button
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          onPressed: () => _updateQuantity(context, id, -qty), // Set to 0 to remove
                          tooltip: 'Remove item',
                        ),
                        // Subtotal
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