// lib/Screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'chatbot_screen.dart';
import 'drawer_screen.dart';
import 'login_screen.dart'; // Add your login screen

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("RNS HealthCare"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.blue),
            onPressed: () => _showNotificationsDialog(user),
          ),
        ],
      ),
      drawer: const DrawerScreen(),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 1) {
            Get.toNamed('/book-appointment');
          } else if (index == 2) {
            Get.toNamed('/instagram');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: "Appointments"),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined), label: "Instagram Feed"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.chat, color: Colors.white),
        onPressed: () => Get.to(() => const ChatbotScreen()),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Slider (optional)
          // const SizedBox(height: 20),

          // About Card
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 4,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('About RNS HealthCare', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(
                    'RNS HealthCare provides comprehensive gynaecological care with modern facilities. Our team of experts offers services from prenatal care to wellness screenings.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                    
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Gallery
          const Text('Clinic Gallery', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: List.generate(4, (i) {
              final images = [
                'assets/images/gallery1.png',
                'assets/images/gallery2.png',
                'assets/images/gallery3.png',
                'assets/images/gallery4.png',
              ];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(image: AssetImage(images[i]), fit: BoxFit.cover),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog(User? user) {
    if (user == null) {
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Login Required'),
          content: const Text('Please log in to view your notifications.'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.to(() => const LoginScreen());
              },
              child: const Text('Login'),
            ),
          ],
        ),
      );
      return;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('notifications')
                      .where('userId', isEqualTo: user.uid)
                      .orderBy('timestamp', descending: true)
                      .limit(20)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(child: Text('No notifications yet'));
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final data = docs[i].data() as Map<String, dynamic>;
                        final date = data['timestamp'] != null
                            ? DateFormat('MMM dd, yyyy HH:mm').format((data['timestamp'] as Timestamp).toDate())
                            : 'Unknown';
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              data['type'] == 'appointment' ? Icons.schedule : Icons.event,
                              color: Colors.blue,
                            ),
                            title: Text(data['title'] ?? 'Notification'),
                            subtitle: Text('${data['body'] ?? ''}\n$date'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              TextButton(onPressed: () => Get.back(), child: const Text('Close')),
            ],
          ),
        ),
      ),
    );
  }
}