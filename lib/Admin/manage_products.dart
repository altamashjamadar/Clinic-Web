import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rns_herbals_app/services/SupabaseService.dart';
// import '../services/supabase_service.dart';

class AdminProductManagement extends StatefulWidget {
  const AdminProductManagement({super.key});

  @override
  State<AdminProductManagement> createState() => _AdminProductManagementState();
}

class _AdminProductManagementState extends State<AdminProductManagement> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _iconController = TextEditingController();
  final _colorController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _uploading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ------------------- UI -------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Manage Products'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // ---- Add Form ----
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _iconController,
                  decoration: const InputDecoration(
                    labelText: 'Icon (e.g., headphones)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _colorController,
                  decoration: const InputDecoration(
                    labelText: 'Color (e.g., purple)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ---- Image Picker ----
                Row(
                  children: [
                    Expanded(
                      child: _selectedImage == null
                          ? const Text('No image selected')
                          : Text(
                              'Selected: ${_selectedImage!.path.split('/').last}'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo),
                      label: const Text('Pick Image'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: _uploading ? null : _addProduct,
                  child: _uploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Add Product'),
                ),
              ],
            ),
          ),

          // ---- Product List ----
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('No products yet'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final docId = docs[i].id;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: data['imageUrl'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  data['imageUrl'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.error),
                                ),
                              )
                            : const Icon(Icons.image, size: 50),
                        title: Text(data['name'] ?? ''),
                        subtitle: Text('₹${data['price'] ?? 0}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editProduct(docs[i]),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteProduct(docId),
                            ),
                          ],
                        ),
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

  // ------------------- LOGIC -------------------
  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _addProduct() async {
    if (_nameController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Name and price are required');
      return;
    }

    setState(() => _uploading = true);
    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await SupabaseService.uploadImage(
          image: _selectedImage!,
          folder: 'products', bucket: '',
        );
      }

      await _firestore.collection('products').add({
        'name': _nameController.text.trim(),
        'desc': _descController.text.trim(),
        'price': int.tryParse(_priceController.text) ?? 0,
        'icon': _iconController.text.trim(),
        'color': _colorController.text.trim(),
        'imageUrl': imageUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar('Success', 'Product added');
      _clearForm();
    } catch (e) {
      Get.snackbar('Error', 'Failed: $e');
    } finally {
      setState(() => _uploading = false);
    }
  }

  // Placeholder edit (you can expand)
  void _editProduct(DocumentSnapshot doc) {
    Get.snackbar('Edit', 'Implement edit dialog for ${doc.id}');
  }

  Future<void> _deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }

  void _clearForm() {
    _nameController.clear();
    _descController.clear();
    _priceController.clear();
    _iconController.clear();
    _colorController.clear();
    setState(() => _selectedImage = null);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _iconController.dispose();
    _colorController.dispose();
    super.dispose();
  }
}