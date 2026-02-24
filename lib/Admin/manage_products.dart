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
        centerTitle: true,
         backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
       floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        // onPressed: (){},
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
         

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
                // if (docs.isEmpty) {
                //   return const Center(child: Text('No products yet'));
                // }
                 if (docs.isEmpty) {
            return const Center(
              child: Text('No products yet\nTap + to add',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            );
          }
                return ListView.builder(
                  
  padding: const EdgeInsets.all(12),
  itemCount: docs.length,
  physics: const ClampingScrollPhysics(),
  itemBuilder: (context, i) {
    final doc = docs[i];
    final data = doc.data() as Map<String, dynamic>;

    final imageUrl = data['imageUrl'] ?? '';
    final name = data['name'] ?? '';
    final price = data['price'] ?? 0;
    final stock = data['quantity'] ?? 0;

    return Card(
      color: Colors.white,
      shadowColor: Colors.grey,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- IMAGE ----------------
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image),
                    )
                  : Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image),
                    ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Stock: $stock quantity',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Price: ₹$price',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                
                  Row(
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text(
                          'Remove',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                        ),
                        onPressed: () =>
                            _deleteProduct(doc.id),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),

                        style: ElevatedButton.styleFrom(
                          
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () =>
                            _showEditDialog(doc),
                      ),
                    ],
                  ),
                ],
              ),
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
void _showAddProductDialog() {
  _clearForm();

  Get.dialog(
    StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Add Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: _nameController,
                  model: FormFieldModel(
                    label: "Name",
                    required: true,
                    hint: "Enter product name",
                  ),
                  showClearButton: false,
                ),
                const SizedBox(height: 10),

                CustomTextField(
                  controller: _descController,
                  model: FormFieldModel(
                    label: "Description",
                    hint: "Enter product description",
                    maxLines: 2,
                  ),
                  showClearButton: false,
                ),
                const SizedBox(height: 10),

                CustomTextField(
                  controller: _priceController,
                  model: FormFieldModel(
                    label: "Price (INR)",
                    required: true,
                    hint: "Enter product price",
                    keyboardType: TextInputType.number,
                  ),
                  showClearButton: false,
                ),
                const SizedBox(height: 10),

                CustomTextField(
                  controller: _stockController,
                  model: FormFieldModel(
                    label: "Available Stock",
                    required: true,
                    hint: "Enter available stock",
                    keyboardType: TextInputType.number,
                  ),
                  showClearButton: false,
                ),
                const SizedBox(height: 12),

                /// IMAGE PICKER ROW
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedImage == null
                            ? 'No image selected'
                            : _selectedImage!.path.split('/').last,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final XFile? picked =
                            await _picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 1200,
                          imageQuality: 85,
                        );

                        if (picked != null) {
                          _selectedImage = File(picked.path);
                          setDialogState(() {}); // 🔥 THIS IS THE FIX
                        }
                      },
                      icon: const Icon(Icons.photo, color: Colors.blue),
                      label: const Text(
                        'Pick Image',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: _uploading
                  ? null
                  : () async {
                      await _addProduct();
                      if (Get.isDialogOpen ?? false) Get.back();
                    },
              child: _uploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Add'),
            ),
          ],
        );
      },
    ),
  );
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