

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rns_herbals_app/model/form_field_model.dart';
import 'package:rns_herbals_app/widgets/custom_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedGender;
  String? _profileImageUrl;
  File? _imageFile;
  bool _uploading = false;

  final User? _user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_user == null) return;
    final doc = await _firestore.collection('users').doc(_user!.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      _nameController.text = data['fullName'] ?? '';
      _phoneController.text = data['phoneNumber'] ?? '';
      _addressController.text = data['address'] ?? '';
      _selectedGender = data['gender'];
      _profileImageUrl = data['profileImage'];
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 800);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _uploading = true;
      });
      await _uploadToSupabase();
    }
  }

  Future<void> _takePhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85, maxWidth: 800);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _uploading = true;
      });
      await _uploadToSupabase();
    }
  }

  
  Future<void> _uploadToSupabase() async {
    if (_imageFile == null || _user == null) {
      setState(() => _uploading = false);
      return;
    }

    final bucket = 'profile-pic';  
    final filePath = '${_user!.uid}.jpg';  

    try {
      // Upload
      await _supabase.storage
          .from(bucket)
          .upload(filePath, _imageFile!, fileOptions: const FileOptions(upsert: true));

      final url = '${_supabase.storage.from(bucket).getPublicUrl(filePath)}?t=${DateTime.now().millisecondsSinceEpoch}';

      print('Uploaded: $url'); 

      setState(() {
        _profileImageUrl = url;
        _uploading = false;
      });


      await _firestore.collection('users').doc(_user!.uid).update({
        'profileImage': url,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Upload error: $e');  
    
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5)
        ),
      );
      setState(() => _uploading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_user == null) {
    
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login required')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

   
    if (_passwordController.text.isNotEmpty) {
      if (_passwordController.text != _confirmPasswordController.text) {
   
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }
      try {
        await _user!.updatePassword(_passwordController.text);
      } catch (e) {
       
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password update failed. Re-login required.')),
        );
        return;
      }
    }

    try {
      await _firestore.collection('users').doc(_user!.uid).set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'gender': _selectedGender,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

     
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
    
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5)
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = _user == null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
         
              const SizedBox(height: 30),

             
              CustomTextField(model: FormFieldModel(label: "Full name", hint: "Enter ful name",prefixIcon: Icons.person), controller: _nameController),
             
              const SizedBox(height: 12),

             
              CustomTextField(model: FormFieldModel(label: "Phone", hint: "Enter phone number",prefixIcon: Icons.phone), controller: _phoneController),
              const SizedBox(height: 12),
              _buildGenderDropdown(enabled: !isGuest),
              const SizedBox(height: 12),
            // email id should not be editable
              _buildTextField(null, 'Email', Icons.email,
                  initialValue: _user?.email ?? 'Guest', enabled: false),
         
            
              const SizedBox(height: 12),
             
              CustomTextField(model: FormFieldModel(label: "Address", hint: "Enter address", prefixIcon: Icons.home, maxLines: 2
              ), controller: _addressController),
              const SizedBox(height: 12),
              
            
              CustomTextField(model: FormFieldModel(label: "New Password (Optional)", hint: "Enter new password",prefixIcon: Icons.lock, fieldType: FieldType.password,), controller: _passwordController),
              const SizedBox(height: 12),
            
              CustomTextField(model: FormFieldModel(label: "Confirm New Password", hint: "Re-enter new password",prefixIcon: Icons.lock, fieldType: FieldType.password,), controller: _confirmPasswordController),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isGuest ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController? controller, String label, IconData icon,
      {String? initialValue, bool enabled = true, bool obscure = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      enabled: enabled,
      obscureText: obscure,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: enabled && controller != null ? (v) => v!.trim().isEmpty ? 'Required' : null : null,
    );
  }

  Widget _buildGenderDropdown({bool enabled = true}) {
    return DropdownButtonFormField<String>(
      // padding: EdgeInsets.all(8.0),
      value: _selectedGender,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        labelText: 'Gender',
        labelStyle: TextStyle(color: enabled ? Colors.blue : Colors.grey),
        prefixIcon: const Icon(Icons.wc,color: Colors.blue,),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(
    
        value: g, child: Text(g))).toList(),
      onChanged: enabled ? (v) => setState(() => _selectedGender = v) : null,
      dropdownColor: Colors.white ,
    );
  }

  void _showImageSourceDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Choose Image Source'),
        actions: [
          TextButton.icon(icon: const Icon(Icons.photo_library), label: const Text('Gallery'), onPressed: () { Get.back(); _pickImage(); }),
          TextButton.icon(icon: const Icon(Icons.camera_alt), label: const Text('Camera'), onPressed: () { Get.back(); _takePhoto(); }),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
