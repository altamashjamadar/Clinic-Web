import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rns_herbals_app/Screens/signup.dart';
import 'package:rns_herbals_app/model/form_field_model.dart';
import 'package:rns_herbals_app/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String? _errorMessage;
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous error
    });
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user; 
      if (user == null) {
        throw Exception('Authentication failed: User is null');
      }

      print('Authenticated user UID: ${user.uid}');


      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      if (!userDoc.exists) {
        throw Exception('User document not found for UID: ${user.uid}. Contact admin.');
      }


      String role = userDoc['role'] as String? ?? 'user';
      print('User role: $role'); 

      switch (role) {
        case 'admin':

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content:  const Text('Welcome, Admin!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5)
            ),
          );
          Get.offAllNamed('/admin-home');
          break;
        case 'doctor':
        
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content:  const Text('Welcome, Doctor!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5)
            ),
          );
          Get.offAllNamed('/doctor');
          break;
        default:
        
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content:  const Text('Welcome, User!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5)
            ),
          );
          Get.offAllNamed('/home');
          
      }
    } catch (e) {
      setState(() {
        String error = e.toString();
        print('Login error: $error'); 
        if (error.contains('wrong-password')) {
          _errorMessage = 'Incorrect password';
        } else if (error.contains('user-not-found')) {
          _errorMessage = 'User not found';
        } else if (error.contains('Authentication failed')) {
          _errorMessage = 'Authentication failed. Please try again.';
        } else if (error.contains('User document not found')) {
          _errorMessage = 'User role not configured. Contact admin.';
        } else {
          _errorMessage = error.split('] ').last;
        }
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/logo.jpeg'),
              fit: BoxFit.cover,
              opacity: 0.1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/pic1.png', height: 250),
                const SizedBox(height: 30),


                CustomTextField(model: FormFieldModel(label: 'Email', hint: 'Enter Your email', prefixIcon:Icons.email ), controller: _emailController),
          
                const SizedBox(height: 20),
                CustomTextField(model: FormFieldModel(label: 'Password', hint: 'Enter Your password', prefixIcon:Icons.lock ,fieldType: FieldType.password,required: true), controller: _passwordController, showPasswordToggle: true,),
               
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Login',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20),
                const Text(
                  'Test: admin@gmail.com/123456 | user@gmail.com/user123',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Get.to(() => const SignupPage());
                  },
                  child: const Text(
                    'Don\'t have an account? Sign Up',
                    style: TextStyle(color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}