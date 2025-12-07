// lib/screens/manage_camps.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rns_herbals_app/services/NotificationService.dart';

class ManageCamps extends StatefulWidget {
  const ManageCamps({super.key});
  @override State<ManageCamps> createState() => _ManageCampsState();
}

class _ManageCampsState extends State<ManageCamps> {
  final _addressController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addCamp() async {
    await NotificationService.sendToAllUsers(
  title: 'New Health Camp Scheduled!',
  body: '$_dateController.text at $_timeController.text\nLocation: $_addressController.text',
);
    if (_addressController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _timeController.text.isEmpty) {
      Get.snackbar('Error', 'Address, Date & Time are required');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('camps').add({
        'address': _addressController.text.trim(),
        'date': _dateController.text.trim(),
        'time': _timeController.text.trim(),
        'description': _descriptionController.text.trim(),
        'status': 'active',
        'timestamp': FieldValue.serverTimestamp(),
      });

      Get.snackbar('Success', 'Camp added!', backgroundColor: Colors.green, colorText: Colors.white);
      _addressController.clear();
      _dateController.clear();
      _timeController.clear();
      _descriptionController.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Manage Camps'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCampDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('camps')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final camps = snapshot.data?.docs ?? [];
          if (camps.isEmpty) {
            return const Center(
              child: Text('No camps yet\nTap + to add', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: camps.length,
            itemBuilder: (context, i) {
              final data = camps[i].data() as Map<String, dynamic>;
              return Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.event, color: Colors.red),
                  title: Text('${data['date']} at ${data['time']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['address'], style: const TextStyle(fontWeight: FontWeight.w500)),
                      if (data['description']?.isNotEmpty == true)
                        Text(data['description'], style: const TextStyle(color: Colors.black87)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCamp(camps[i].reference),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddCampDialog() {
    _addressController.clear();
    _dateController.clear();
    _timeController.clear();
    _descriptionController.clear();

    Get.dialog(
      AlertDialog(
        title: const Text('Add New Camp'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Address
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address *',
                  prefixIcon: Icon(Icons.location_on, color: Colors.red),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              // Date Picker
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date *',
                  prefixIcon: Icon(Icons.calendar_today, color: Colors.blue),
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2026),
                  );
                  if (picked != null) {
                    _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
                  }
                },
              ),
              const SizedBox(height: 12),

              // Time Picker
              TextFormField(
                controller: _timeController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Time *',
                  prefixIcon: Icon(Icons.access_time, color: Colors.blue),
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    _timeController.text = picked.format(context);
                  }
                },
              ),
              const SizedBox(height: 12),

              // Description (Optional)
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: _isLoading ? null : () {
              _addCamp();
              Get.back();
            },
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCamp(DocumentReference ref) async {
    final confirm = await Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete Camp'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      await ref.delete();
      Get.snackbar('Deleted', 'Camp removed');
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}