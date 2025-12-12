
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rns_herbals_app/model/form_field_model.dart';
import 'package:rns_herbals_app/services/SupabaseService.dart';
import './../widgets/custom_text_field.dart';

class AdminProductManagement extends StatefulWidget {
  const AdminProductManagement({super.key});

  @override
  State<AdminProductManagement> createState() => _AdminProductManagementState();
}

class _AdminProductManagementState extends State<AdminProductManagement> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController(); 

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _uploading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Manage Products'),
         backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
         
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
               CustomTextField(
                  controller: _nameController, model: FormFieldModel(label: "Name",required: true, hint: "Enter product name"),
                  
                ),
               
                const SizedBox(height: 10),
                
               
                CustomTextField(
                  controller: _descController, model: FormFieldModel(label: "Description", hint: "Enter product description", maxLines: 2),
                ),
                const SizedBox(height: 10),

                CustomTextField(
                  controller: _priceController, model: FormFieldModel(label: "Price (INR)",required: true, hint: "Enter product price", keyboardType: TextInputType.number),
                ),
                const SizedBox(height: 10),

                
                CustomTextField(
                  controller: _stockController, model: FormFieldModel(label: "Available Stock (quantity)",required: true, hint: "Enter available stock", keyboardType: TextInputType.number),
                ),
                const SizedBox(height: 12),

                
                Row(
                  children: [
                    Expanded(
                      child: _selectedImage == null
                          ? const Text('No image selected')
                          : Text('Selected: ${_selectedImage!.path.split('/').last}'),
                    ),
                    ElevatedButton.icon(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blue),
                      ),
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo, color: Colors.white,),
                      label: const Text('Pick Image',style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: _uploading ? null : _addProduct,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                  ),
                  child: _uploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Add Product',style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

  
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('products').orderBy('createdAt', descending: true).snapshots(),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    final data = doc.data() as Map<String, dynamic>;
                    final docId = doc.id;

                    final imageUrl = (data['imageUrl'] as String?) ?? '';
                    final name = (data['name'] as String?) ?? '';
                    final price = (data['price'] ?? 0).toString();
                    final qty = (data['quantity'] ?? data['stock'] ?? 0).toString();

                    return Card(
                      color: Colors.white,
                      shadowColor: Colors.grey.shade200,
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                      child: ListTile(
                        
                        leading: imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                ),
                              )
                            : Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade200,
                                ),
                                child: const Icon(Icons.image, color: Colors.grey),
                              ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Price: ₹$price'),
                            const SizedBox(height: 2),
                            Text('Available stock: $qty'),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditDialog(doc),
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
    final name = _nameController.text.trim();
    final price = int.tryParse(_priceController.text) ?? -1;
    final quantity = int.tryParse(_stockController.text) ?? -1;

    if (name.isEmpty || price < 0 || quantity < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide valid name, price and stock (>= 0)')),
      );
      return;
    }

    setState(() => _uploading = true);
    try {
      String? imageUrl;
      if (_selectedImage != null) {

        imageUrl = await SupabaseService.uploadImage(
          image: _selectedImage!,
          bucket: 'products',
          folder: 'items',
        );
      }

      await _firestore.collection('products').add({
        'name': name,
        'desc': _descController.text.trim(),
        'price': price,
        'quantity': quantity,
        'imageUrl': imageUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );
      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add product: $e')),
      );
    } finally {
      setState(() => _uploading = false);
    }
  }

  
  void _showEditDialog(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final nameCtrl = TextEditingController(text: data['name'] ?? '');
    final descCtrl = TextEditingController(text: data['desc'] ?? '');
    final priceCtrl = TextEditingController(text: (data['price'] ?? '').toString());
    final qtyCtrl = TextEditingController(text: (data['quantity'] ?? data['stock'] ?? 0).toString());

    File? editImage;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx2, setStateDialog) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [

            
                CustomTextField(
                  controller: nameCtrl, model: FormFieldModel(label: "Name",required: true, hint: "Enter product name"),
                ),
                const SizedBox(height: 8),
            
                CustomTextField(
                  controller: descCtrl, model: FormFieldModel(label: "Description", hint: "Enter product description", maxLines: 2),
                ),
                const SizedBox(height: 8),
            
                CustomTextField(
                  controller: priceCtrl, model: FormFieldModel(label: "Price (INR)",required: true, hint: "Enter product price", keyboardType: TextInputType.number),
                ),
                const SizedBox(height: 8),
            
                CustomTextField(
                  controller: qtyCtrl, model: FormFieldModel(label: "Available Stock (quantity)",required: true, hint: "Enter available stock", keyboardType: TextInputType.number),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: Text(editImage == null ? 'No new image' : 'Selected: ${editImage?.path.split('/').last}')),
                    TextButton.icon(
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(Colors.blue),
                      ),
                      onPressed: () async {
                        final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 85);
                        if (picked != null) {
                          editImage = File(picked.path);
                          setStateDialog(() {}); // refresh the dialog UI
                        }
                      },
                      icon: const Icon(Icons.photo,color: Colors.blue,),
                      label: const Text('Pick',style: TextStyle(color: Colors.blue),),
                    
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel',style: TextStyle(color: Colors.blue),),),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  String? updatedImageUrl;
                  if (editImage != null) {
                    updatedImageUrl = await SupabaseService.uploadImage(image: editImage!, bucket: 'products', folder: 'items');
                  }
                  await _firestore.collection('products').doc(doc.id).update({
                    'name': nameCtrl.text.trim(),
                    'desc': descCtrl.text.trim(),
                    'price': int.tryParse(priceCtrl.text) ?? 0,
                    'quantity': int.tryParse(qtyCtrl.text) ?? 0,
                    if (updatedImageUrl != null) 'imageUrl': updatedImageUrl,
                    'updatedAt': FieldValue.serverTimestamp(),
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product updated'), backgroundColor: Colors.green));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
                }
              },
              child: const Text('Save',style: TextStyle(color: Colors.white),
            )
            )
          ],
        );
      }),
    );
  }

  Future<void> _deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product deleted')));
  }

  void _clearForm() {
    _nameController.clear();
    _descController.clear();
    _priceController.clear();
    _stockController.clear();
    setState(() => _selectedImage = null);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }
}