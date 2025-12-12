import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rns_herbals_app/Admin/manage_news.dart';
import 'package:rns_herbals_app/Admin/manage_orders.dart';
import 'package:rns_herbals_app/Admin/manage_products.dart';


class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
   Map<String, dynamic>? userData; 
   bool isLoading = true;

     @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            userData = doc.data();
            isLoading = false;
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
      final user = FirebaseAuth.instance.currentUser;

    return Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            if (isLoading)
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              accountName: Text('Loading...'),
              accountEmail: Text('Please wait'),
            )
          else
            GestureDetector(
              onTap: () {
                Get.toNamed('/profile');
              },
              child: UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.blue),
                accountName: Text(
                  user != null
                      ? (user.displayName ??
                         (userData?['fullName'] as String?) ??
                         user.email!.split('@')[0])
                      : 'Guest User',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                accountEmail: Text(
                  user?.email ?? 'guest@example.com',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                margin: EdgeInsets.zero,
              ),
            ),
            
            if(user?.email == 'admin@gmail.com')...[
              ListTile(
                leading: const Icon(Icons.schedule, color: Colors.blue),
                title: const Text('Appointments'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/admin-appointments');
                },
              ),
             
             
              ListTile(
                leading: const Icon(Icons.article, color: Colors.blue),
                title: const Text('Add News'),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(ManageNews());
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_hospital, color: Colors.blue),
                title: const Text('Create Camps'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/manage-camps');
                },
              ),
              ListTile(
                leading: const Icon(Icons.inventory, color: Colors.blue),
                title: const Text('Manage Products'),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(AdminProductManagement());
                }
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart, color: Colors.blue),
                title: const Text('View Orders'),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(ManageOrders());
                },
              ),
           
            
            ]else ...[
            ListTile(
              leading: const Icon(Icons.home_outlined, color: Colors.blue),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed('/home');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.blue,
              ),
              title: const Text('Instagram Feed'),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed('/instagram');
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month, color: Colors.blue),
              title: const Text('Book Appointment'),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed('/book-appointment');
              },
            ),
              ListTile(
              leading: const Icon(Icons.production_quantity_limits, color: Colors.blue),
              title: const Text('Products'),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed('/product');
              },
              ),
            ListTile(
              leading: const Icon(Icons.chat_outlined, color: Colors.blue),
              title: const Text('Chatbot'),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed('/chatbot');
              },
            ),
            ListTile(
              leading: const Icon(Icons.article_outlined, color: Colors.blue),
              title: const Text('News'),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed('/news');
                // Get.to(NewsPage());
              },
            ),
            ListTile(leading: Icon(Icons.event,color: Colors.blue,), title: Text('Camps'), onTap: () => Get.toNamed('/camps'), ),
            // Spacer(),
            ],
          
            if (user == null)
            
              ListTile(
                leading: const Icon(Icons.login, color: Colors.blue),
                title: const Text('Login'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/login');
                },
              ),
            if (user != null)
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.blue),
                title: const Text('Logout'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                  Get.offAllNamed('/home');
                  // Get.snackbar('Logged Out', 'Please login again');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
              ),
          ],
          ),
    );
    
  }
}