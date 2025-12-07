// // lib/screens/manage_orders.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ManageOrders extends StatefulWidget {
  const ManageOrders({super.key});

  @override
  State<ManageOrders> createState() => _ManageOrdersState();
}

class _ManageOrdersState extends State<ManageOrders> {
  String _searchQuery = '';
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Manage Orders',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
          
            padding: 
            const EdgeInsets.all(12),
            child: TextField(
              
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search by order ID, user, or product',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),

          // Orders List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('orders').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var orders = snapshot.data!.docs;

                // Apply Filters
                if (_filterStatus != 'all') {
                  orders = orders.where((doc) => (doc['status'] ?? 'pending') == _filterStatus).toList();
                }

                if (_searchQuery.isNotEmpty) {
                  orders = orders.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final orderId = doc.id.toLowerCase();
                    final userName = (data['userName'] ?? '').toString().toLowerCase();
                    final items = data['items'] as List<dynamic>? ?? [];
                    final productNames = items.map((i) => (i['name'] ?? '').toString().toLowerCase()).join(' ');
                    return orderId.contains(_searchQuery) ||
                        userName.contains(_searchQuery) ||
                        productNames.contains(_searchQuery);
                  }).toList();
                }

                if (orders.isEmpty) {
                  return const Center(child: Text('No orders found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final orderDoc = orders[index];
                    final data = orderDoc.data() as Map<String, dynamic>;
                    final orderId = orderDoc.id;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(data['status']),
                          child: Text(orderId.substring(0, 2).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        title: Text('Order #$orderId', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${data['userName'] ?? 'Unknown User'} • ${data['userPhone'] ?? ''}'),
                            Text('Total: ₹${data['totalPrice']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        trailing: _buildStatusChip(data['status']),
                        children: [
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Items
                                ...((data['items'] as List<dynamic>?) ?? []).map((item) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        children: [
                                          if (item['imageUrl'] != null)
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(item['imageUrl'], width: 40, height: 40, fit: BoxFit.cover),
                                            ),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text('${item['name']}')),
                                          Text('x${item['quantity']}'),
                                          Text(' ₹${item['price'] * item['quantity']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    )),

                                const SizedBox(height: 12),
                                const Divider(),

                                // Address
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16),
                                    const SizedBox(width: 4),
                                    Expanded(child: Text(data['address'] ?? 'No address')),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Status Update
                                Row(
                                  children: [
                                    const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    DropdownButton<String>(
                                      value: data['status'] ?? 'pending',
                                      items: ['pending', 'processing', 'shipped', 'delivered', 'cancelled']
                                          .map((s) => DropdownMenuItem(value: s, child: Text(s.capitalizeFirst!)))
                                          .toList(),
                                      onChanged: (newStatus) => _updateStatus(orderDoc.reference, newStatus),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filter by Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...['all', 'pending', 'processing', 'shipped', 'delivered', 'cancelled'].map((status) => RadioListTile<String>(
                  title: Text(status == 'all' ? 'All Orders' : status.capitalizeFirst!),
                  value: status,
                  groupValue: _filterStatus,
                  onChanged: (val) {
                    setState(() => _filterStatus = val!);
                    Get.back();
                  },
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(DocumentReference ref, String? newStatus) async {
    if (newStatus == null) return;
    final confirm = await Get.dialog(
      AlertDialog(
        title: const Text('Update Status'),
        content: Text('Change status to "$newStatus"?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('Update')),
        ],
      ),
    );
    if (confirm == true) {
      await ref.update({'status': newStatus});
      Get.snackbar('Success', 'Status updated to $newStatus', backgroundColor: Colors.green, colorText: Colors.white);
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'processing': return Colors.blue;
      case 'shipped': return Colors.purple;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildStatusChip(String? status) {
    return Chip(
      label: Text(status?.capitalizeFirst ?? 'Pending', style: const TextStyle(color: Colors.white)),
      backgroundColor: _getStatusColor(status),
    );
  }
}