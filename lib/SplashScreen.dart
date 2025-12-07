import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rns_herbals_app/Screens/intro_slider.dart';
import 'package:rns_herbals_app/Screens/app_routes.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () async {
      if (FirebaseAuth.instance.currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();
        String role = userDoc['role'] ?? 'user';
        Get.offAllNamed(
            role == 'admin' ? '/admin-home' : role == 'doctor' ? '/doctor' : '/home');
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => IntroSliderPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Image.asset(
            'assets/logo.jpeg',
            width: 250,
            height: 250,
          ),
        ),
      ),
    );
  }
}