import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:rns_herbals_app/model/form_field_model.dart';
import 'package:rns_herbals_app/widgets/custom_text_field.dart';
import 'login_screen.dart'; 
import './CartScreen.dart'; 

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

Future<int?> _showQtyDialog(int available) async {
  int qty = 1;
  return showDialog<int>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Choose quantity',),
      alignment: Alignment.center,
      content: StatefulBuilder(builder: (c, setState) {
        return SizedBox(
          height: 140,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Available: $available'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: qty > 1 ? () => setState(() => qty--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$qty', style: const TextStyle(fontSize: 18)),
                  IconButton(
                    onPressed: qty < available ? () => setState(() => qty++) : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Or type quantity'),//
                onChanged: (v) {
                  final parsed = int.tryParse(v) ?? qty;
                  if (parsed >= 1 && parsed <= available) setState(() => qty = parsed);
                },
              ),
            ],
          ),
        );
      }),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel',style: TextStyle(color: Colors.blue),)),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue),
          ), onPressed: () => Navigator.pop(ctx, qty), child: const Text('Add',style: TextStyle(color: Colors.white),))
      ],
    ),
  );
}

Future<void> _addToCart(Map<String, dynamic> product) async {
  if (_user == null) {
    Get.to(() => const LoginScreen());
    return;
  }

  final productId = (product['id'] ?? '') as String;
  final available = (product['quantity'] ?? 0) as int;
  if (available <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This product is unavailable')));
    return;
  }

  final qty = await _showQtyDialog(available);
  if (qty == null || qty <= 0) return;

  final prodRef = _firestore.collection('products').doc(productId);
  final cartRef = _firestore.collection('carts').doc(_user!.uid);

  try {
    await _firestore.runTransaction((tx) async {
   
      final prodSnap = await tx.get(prodRef);
      final cartSnap = await tx.get(cartRef);

      if (!prodSnap.exists) throw Exception('Product not found');
   
      final prodData = Map<String, dynamic>.from(prodSnap.data() as Map);
      final currentQty = (prodData['quantity'] ?? 0) as int;
      if (currentQty < qty) throw Exception('Only $currentQty items available');

      final fieldKey = 'items.$productId';



      if (cartSnap.exists) {
        tx.update(cartRef, {
          fieldKey: FieldValue.increment(qty),
          'totalItems': FieldValue.increment(qty),
        });
      } else {
        tx.set(cartRef, {
          'items': {productId: qty},
          'totalItems': qty,
        });
      }
    });

    setState(() => cartCount += qty);
    print('Added $qty of ${product['name']} to cart');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${product['name']} x$qty added to cart'),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
    ));
  } catch (e) {
    print('Add to cart failed: $e');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Failed to add to cart: ${e.toString()}'),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
    ));
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Products',style: TextStyle(color: Colors.white),),
        centerTitle:true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.shopping_cart,color: Colors.white,), onPressed: () => Get.to(() => const CartScreen())),
              if (cartCount > 0) Positioned(right: 8, top: 8, child: CircleAvatar(radius: 8, backgroundColor: Colors.red, child: Text('$cartCount', style: const TextStyle(fontSize: 10)))),
            ],
          ),
        ],
      ),
      body: filtered.isEmpty
    ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No products available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Please check back later',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
    : ListView.builder(
        physics: const ClampingScrollPhysics(),
        itemCount: filtered.length,
        itemBuilder: (context, i) {
          final p = filtered[i];
          final inStock = (p['quantity'] ?? 0) > 0;

          return Card(
            color: Colors.white,
            child: ListTile(
              leading: p['imageUrl'] != null && p['imageUrl'].toString().isNotEmpty
                  ? Image.network(
                      p['imageUrl'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image, size: 40),
              title: Text(p['name'] ?? ''),
              subtitle: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('₹${p['price']}'),
                  Text(
                    'Stock: ${p['quantity'] ?? 0}',
                    style: TextStyle(
                      color: inStock ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: inStock ? Colors.blue : Colors.grey,
                ),
                onPressed: inStock ? () => _addToCart(p) : null,
                child: Text(
                  inStock ? 'Add' : 'Out of Stock',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),

      // body: ListView.builder(
      //   physics: const ClampingScrollPhysics(),
      //   itemCount: filtered.length,
      //   itemBuilder: (context, i) {
      //     final p = filtered[i];
      //     final inStock = (p['quantity'] ?? 0) > 0;

      //     return Card(
      //       color: Colors.white,
      //       child: ListTile(
      //         leading: p['imageUrl'] != null ? Image.network(p['imageUrl'], width: 60, height: 60, fit: BoxFit.cover) : const Icon(Icons.image),
      //         title: Text(p['name']),
      //         subtitle: Column(
      //           mainAxisSize: MainAxisSize.min, 
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             Text('₹${p['price']}'),
      //             Text('Stock: ${p['quantity'] ?? 0}', style: TextStyle(color: inStock ? Colors.green : Colors.red)),
      //           ],
      //         ),
      //         trailing: ElevatedButton(
      //           style: ButtonStyle(
      //             backgroundColor: MaterialStateProperty.all(inStock ? Colors.blue : Colors.grey),
      //           ),
      //           onPressed: inStock ? () => _addToCart(p) : null,
      //           child: Text(inStock ? 'Add' : 'Out of Stock',style: TextStyle(color: Colors.white),),
      //         ),
      //       ),
      //     );
      //   },
      // ),
    );
  }
}