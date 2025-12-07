
// lib/Screens/signup.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // 1. Create user
      UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Save profile
      await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
        'fullName': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Send verification email
      await cred.user!.sendEmailVerification();

      Get.snackbar(
        'Check Your Email',
        'Verification link sent to ${_emailController.text}',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
      );

      // 4. Go to verification screen
      Get.offAll(() => VerifyEmailScreen(user: cred.user!));
    } on FirebaseAuthException catch (e) {
      String msg = 'Signup failed';
      if (e.code == 'weak-password') msg = 'Password too weak';
      if (e.code == 'email-already-in-use') msg = 'Email already registered';
      Get.snackbar('Error', msg);
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up,')
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name *'), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone *'), keyboardType: TextInputType.phone, validator: (v) => v!.length != 10 ? '10 digits' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email *'), keyboardType: TextInputType.emailAddress, validator: (v) => !GetUtils.isEmail(v!) ? 'Invalid email' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password *'), validator: (v) => v!.length < 6 ? 'Min 6 chars' : null),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _signup,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Verification Screen

class VerifyEmailScreen extends StatefulWidget {
  final User user;
  const VerifyEmailScreen({super.key, required this.user});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _countdown = 30;
  Timer? _timer;
  bool _canResend = true;

  @override
  void initState() {
    super.initState();

    // Animation
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    // Auto-check every 3 seconds
    Timer.periodic(const Duration(seconds: 3), (_) => _checkVerified());
  }

  Future<void> _checkVerified() async {
    await widget.user.reload();
    if (widget.user.emailVerified) {
      Get.offAllNamed('/home');
      Get.snackbar(
        'Verified!',
        'Welcome to RNS HealthCare 🎉',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _resendEmail() async {
    if (!_canResend) return;

    setState(() {
      _canResend = false;
      _countdown = 30;
    });

    await widget.user.sendEmailVerification();

    Get.snackbar(
      'Sent!',
      'Verification email sent again',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );

    // Start countdown
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        setState(() => _canResend = true);
        timer.cancel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: FadeTransition(
            opacity: _animation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Icon
                ScaleTransition(
                  scale: _animation,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_read,
                      size: 80,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Subtitle
                Text(
                  'We sent a verification link to',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.user.email!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 24),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Text(
                    'Click the link in the email to verify your account.\n'
                    'You may need to check your spam/junk folder.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 32),

                // Resend Button with Countdown
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _canResend ? _resendEmail : null,
                    icon: const Icon(Icons.send),
                    label: Text(_canResend ? 'Resend Verification Email' : 'Wait $_countdown sec'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canResend ? Colors.blue : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Logout Option
                TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Get.offAllNamed('/login');
                  },
                  child: const Text(
                    'Use a different email',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}