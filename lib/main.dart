import 'package:clinic_web/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';

import 'package:get/get.dart';

void main() async {
 WidgetsFlutterBinding.ensureInitialized();

 await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]); 
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  // const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  // const InitializationSettings initSettings = InitializationSettings(android: androidInit);
  
  runApp(const ClinicWebApp());
}

class ClinicWebApp extends StatefulWidget {
  const ClinicWebApp({super.key});

  @override
  State<ClinicWebApp> createState() => _ClinicWebAppState();
}

class _ClinicWebAppState extends State<ClinicWebApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: GetMaterialApp(
        scrollBehavior: const MaterialScrollBehavior().copyWith(
    overscroll: false,
        ),
        debugShowCheckedModeBanner: false,
        title: 'Clinic Web',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
        home:  LoginScreen(), 
        
      ),
    );
  }
}

