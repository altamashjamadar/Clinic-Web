import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rns_herbals_app/Screens/home_page.dart';
import 'package:rns_herbals_app/Screens/login_screen.dart';
import 'package:rns_herbals_app/model/form_field_model.dart';
import 'package:rns_herbals_app/widgets/custom_text_field.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;
  bool _loading = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  Future<void> _placeOrder() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty || phone.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (_user == null) {
      Get.to(() => const LoginScreen());
      return;
    }

    setState(() => _loading = true);
    try {
      final cartRef = _firestore.collection('carts').doc(_user!.uid);

      await _firestore.runTransaction((tx) async {
        // Step 1: All READS first
        final cartSnap = await tx.get(cartRef);
        if (!cartSnap.exists) throw Exception('Cart not found');
        final items = Map<String, dynamic>.from(cartSnap.data()?['items'] ?? <String, dynamic>{});
        if (items.isEmpty) throw Exception('Cart is empty');

        final productIds = items.keys.toList();
        final prodRefs = productIds.map((id) => _firestore.collection('products').doc(id)).toList();
        final prodSnaps = await Future.wait(prodRefs.map((ref) => tx.get(ref)));

        // Validate stock and collect order data
        List<Map<String, dynamic>> orderItems = [];
        double total = 0.0;

        for (int i = 0; i < productIds.length; i++) {
          final prodId = productIds[i];
          final qty = items[prodId] as int;
          final prodSnap = prodSnaps[i];

          if (!prodSnap.exists) throw Exception('Product not found: $prodId');
          final pData = Map<String, dynamic>.from(prodSnap.data() as Map);
          final stock = (pData['quantity'] ?? 0) as int;
          if (stock < qty) throw Exception('Insufficient stock for ${pData['name'] ?? 'Product'}: $stock < $qty');

          final price = ((pData['price'] ?? 0) as num).toDouble();
          orderItems.add({
            'productId': prodId,
            'name': pData['name'] ?? '',
            'price': price,
            'quantity': qty,
            'imageUrl': pData['imageUrl'] ?? '',
          });
          total += price * qty;
        }


        for (int i = 0; i < productIds.length; i++) {
          final prodId = productIds[i];
          final qty = items[prodId] as int;
          final prodRef = _firestore.collection('products').doc(prodId);
          tx.update(prodRef, {'quantity': FieldValue.increment(-qty)});
        }

        final orderRef = _firestore.collection('orders').doc();
        tx.set(orderRef, {
          'userId': _user!.uid,
          'userName': name,
          'userPhone': phone,
          'address': address,
          'items': orderItems,
          'totalPrice': total,
          'status': 'pending',
          'timestamp': FieldValue.serverTimestamp(),
        });

        tx.delete(cartRef);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 5),
        ),
      );
      Get.offAll(() => const HomePage());
    } catch (e) {
      print('Failed to place order: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: ${e.toString()}')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout',style: TextStyle(color:Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () => Get.to(() => const LoginScreen()),
            child: const Text('Login to checkout'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout',style: TextStyle(color:Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(model: FormFieldModel(label: "Full Name", hint: "Enter Full Name",required: true), controller: _nameController,),
          
            const SizedBox(height: 16),
            CustomTextField(model: FormFieldModel(label: "Phone Number", hint: "Enter Phone Number",required: true,keyboardType:TextInputType.phone ), controller: _phoneController),
           
            const SizedBox(height: 16),
          
            CustomTextField(model: FormFieldModel(label: "Delivery Address", hint: "Enter Delivery Address",required: true, maxLines: 3), controller: _addressController),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                ),
                onPressed: _loading ? null : _placeOrder,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Place Order',style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}