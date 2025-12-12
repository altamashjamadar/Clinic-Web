import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rns_herbals_app/Admin/manage_news.dart';
import 'package:rns_herbals_app/Screens/drawer_screen.dart';
import 'admin_appointments.dart';
import 'manage_camps.dart';
import 'manage_products.dart';
import 'manage_orders.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "RNS Clinic Admin",
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
     
      ),
      drawer: const DrawerScreen(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Greeting
              Text(
                'Welcome back, Admin!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Here\'s what\'s happening today',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),

              // Appointment Status (kept)
              _buildAppointmentCard(context),

              const SizedBox(height: 20),

              // Quick Actions (kept and redesigned)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  // small helper action (optional)
                  TextButton(
                    onPressed: () {
                      // optional: navigate to appointments list
                      Get.to(() => const AdminAppointments());
                    },
                    child: const Text('View All', style: TextStyle(color: Colors.blue)),
                  )
                ],
              ),
              const SizedBox(height: 12),
              _buildQuickActionsGrid(context),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

    );
  }

  // Reusable Card
  Widget _card({required String title, required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // small title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // 1. Appointment Status
  Widget _buildAppointmentCard(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('appointments').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _card(
            title: 'Appointment Status',
            child: const Center(child: SizedBox(height: 48, width: 48, child: CircularProgressIndicator())),
          );
        }

        final docs = snapshot.data!.docs;
        final pending = docs.where((d) => (d.data() as Map<String, dynamic>)['status'] == 'pending').length;
        final accepted = docs.where((d) => (d.data() as Map<String, dynamic>)['status'] == 'accepted').length;
        final rejected = docs.where((d) => (d.data() as Map<String, dynamic>)['status'] == 'rejected').length;

        return _card(
          title: 'Appointment Status',
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statusTile(context, 'Pending', pending, Icons.schedule, Colors.orange),
                  _statusTile(context, 'Accepted', accepted, Icons.check_circle, Colors.green),
                  _statusTile(context, 'Rejected', rejected, Icons.cancel, Colors.red),
                ],
              ),
              const SizedBox(height: 12),
              // quick appointment actions row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Get.to(() => const AdminAppointments()),
                    icon: const Icon(Icons.list_alt, size: 18,color: Colors.blue,),
                    label: const Text('Manage Appointments',style: TextStyle(color: Colors.blue),),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusTile(BuildContext context, String label, int count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withOpacity(0.12),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$count',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        label,
                        style: TextStyle(fontSize: 11, color: color.withOpacity(0.9)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      {'icon': Icons.schedule, 'label': 'Appointments', 'page': const AdminAppointments()},
      {'icon': Icons.article, 'label': 'Add News', 'page': const ManageNews()},
      {'icon': Icons.event, 'label': 'Create Camp', 'page': const ManageCamps()},
      {'icon': Icons.inventory_2, 'label': 'Manage Products', 'page': const AdminProductManagement()},
      {'icon': Icons.shopping_bag, 'label': 'View Orders', 'page': const ManageOrders()},
    ];

    return _card(
      title: '',
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: actions.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        itemBuilder: (context, i) {
          final act = actions[i];
          return InkWell(
            onTap: () => Get.to(() => act['page'] as Widget),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.08)),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 4))],
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color.fromARGB(255, 117, 203, 229).withOpacity(0.12),
                    child: Icon(act['icon'] as IconData, color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    act['label'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}
