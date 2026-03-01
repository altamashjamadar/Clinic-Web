import 'dart:async';

import 'package:clinic_web/model/form_field_model.dart';
import 'package:clinic_web/screens/Home_Screen.dart';
import 'package:clinic_web/widgets/Responsive_Wrapper.dart';
import 'package:clinic_web/widgets/custom_text_field.dart';
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
   
      UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

 
      await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
        'fullName': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

   
      await cred.user!.sendEmailVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification link sent to ${_emailController.text}'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
        ),
      );  
    
      Get.offAll(() => VerifyEmailScreen(user: cred.user!));
    } on FirebaseAuthException catch (e) {
      String msg = 'Signup failed';
      if (e.code == 'weak-password') msg = 'Password too weak';
      if (e.code == 'email-already-in-use') msg = 'Email already registered';
     
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:  Text(msg)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:  const Text('Something went wrong')),
      );
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
      appBar: AppBar(title: const Text('Sign Up',style: TextStyle(color: Colors.white),
    
      ),
      centerTitle: true,
      backgroundColor: Colors.blue  ,
      foregroundColor: Colors.white,
      ),
      body: ResponsiveWrapper(
        child: SafeArea(
          child: Center(
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
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                     Image.asset('assets/pic.png', height: 250),
                      const SizedBox(height: 30),
            
                   CustomTextField(model: FormFieldModel(label: 'Full Name', hint: 'Please Enter Full Name',prefixIcon: Icons.person,required: true), controller: _nameController),
                   
                    const SizedBox(height: 16),
                    CustomTextField(model: FormFieldModel(label: "Phone", hint: "Enter Phone number",prefixIcon: Icons.phone,required: true,), controller: _phoneController),//country code picker can be added
                    // date feild last menses date can be added here
                
                    const SizedBox(height: 16),
                    CustomTextField(model: FormFieldModel(label: 'Email', hint: 'Please Enter Email', keyboardType: TextInputType.emailAddress,prefixIcon: Icons.mail,required: true), controller: _emailController),
                
                    const SizedBox(height: 16),
                    CustomTextField(model: FormFieldModel(label: 'Password', hint: 'Enter Your password', fieldType: FieldType.password, required: true,prefixIcon: Icons.lock), controller: _passwordController, showPasswordToggle: true,),
                
                    const SizedBox(height: 24),
                
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
                          onPressed: _isLoading ? null : _signup,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }
}

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


    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();


    Timer.periodic(const Duration(seconds: 3), (_) => _checkVerified());
  }

  Future<void> _checkVerified() async {
    await widget.user.reload();
    if (widget.user.emailVerified) {
      // Get.offAllNamed('/home');
      Get.offAll(() => const HomePage(userName: ''));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome to RNS HealthCare 🎉'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 5),
        ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification email sent again'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );

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


                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),


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

