
// lib/screens/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
      _nameController.text = data['name'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _addressController.text = data['address'] ?? '';
      _selectedGender = data['gender'];
      _profileImageUrl = data['profileImage'];
      setState(() {});
    }
  }

  // Pick from Gallery
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

  // Take Photo
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

  // Upload to Supabase (Fixed: Correct bucket, path, error handling)
  Future<void> _uploadToSupabase() async {
    if (_imageFile == null || _user == null) {
      setState(() => _uploading = false);
      return;
    }

    final bucket = 'profile-pic';  // Your bucket name (must match dashboard)
    final filePath = '${_user!.uid}.jpg';  // Simple path

    try {
      // Upload
      await _supabase.storage
          .from(bucket)
          .upload(filePath, _imageFile!, fileOptions: const FileOptions(upsert: true));

      // Get URL with cache-buster
      final url = '${_supabase.storage.from(bucket).getPublicUrl(filePath)}?t=${DateTime.now().millisecondsSinceEpoch}';

      print('Uploaded: $url');  // Check this in console

      setState(() {
        _profileImageUrl = url;
        _uploading = false;
      });

      // Save to Firestore
      await _firestore.collection('users').doc(_user!.uid).update({
        'profileImage': url,
      });

      Get.snackbar('Success', 'Profile picture updated!', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      print('Upload error: $e');  // Check this log
      Get.snackbar('Error', 'Upload failed: $e', backgroundColor: Colors.red, colorText: Colors.white);
      setState(() => _uploading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_user == null) {
      Get.snackbar('Error', 'Login required');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    // Password optional
    if (_passwordController.text.isNotEmpty) {
      if (_passwordController.text != _confirmPasswordController.text) {
        Get.snackbar('Error', 'Passwords do not match');
        return;
      }
      try {
        await _user!.updatePassword(_passwordController.text);
      } catch (e) {
        Get.snackbar('Error', 'Password update failed. Re-login required.');
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

      Get.snackbar('Success', 'Profile updated!', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Update failed: $e');
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
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blue.shade100,
                    child: _uploading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                            ? ClipOval(child: Image.network(_profileImageUrl!, width: 120, height: 120, fit: BoxFit.cover))
                            : const Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  if (!isGuest)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 30),

              // Form Fields
              _buildTextField(_nameController, 'Full Name', Icons.person, enabled: !isGuest),
              const SizedBox(height: 12),
              _buildTextField(_phoneController, 'Phone', Icons.phone, enabled: !isGuest),
              const SizedBox(height: 12),
              _buildGenderDropdown(enabled: !isGuest),
              const SizedBox(height: 12),
              _buildTextField(null, 'Email', Icons.email, initialValue: _user?.email ?? 'guest@example.com', enabled: false),
              const SizedBox(height: 12),
              _buildTextField(_addressController, 'Address', Icons.home, enabled: !isGuest, maxLines: 2),
              const SizedBox(height: 12),
              _buildTextField(_passwordController, 'New Password (Optional)', Icons.lock, obscure: true, enabled: !isGuest),
              const SizedBox(height: 12),
              _buildTextField(_confirmPasswordController, 'Confirm Current Password', Icons.lock, obscure: true, enabled: !isGuest),
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
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: const Icon(Icons.wc),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
      onChanged: enabled ? (v) => setState(() => _selectedGender = v) : null,
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