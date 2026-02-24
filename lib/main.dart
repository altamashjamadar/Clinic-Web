import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rns_herbals_app/Screens/app_routes.dart';
import 'package:get/get.dart';
// import 'package:rns_herbals_app/settings/settings_controller.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flex_color_scheme/flex_color_scheme.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';

// import 'settings/settings_controller.dart';
// import 'settings/settings_screen.dart';
// import 'l10n/app_localizations.dart';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _showLocalNotification(message);
  print('Background message: ${message.notification?.body}');
}

Future<void> _showLocalNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'high_importance_channel',
    'High Importance Notifications',
    channelDescription: 'Important notifications',
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    message.notification?.title ?? 'RNS Clinic',
    message.notification?.body ?? '',
    notificationDetails,
  );
}

Future<void> setupFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;


  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    String? token = await messaging.getToken();
    final user = FirebaseAuth.instance.currentUser;

    if (token != null && user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'fcmToken': token});
      } catch (e) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'fcmToken': token, 'role': 'user'}, SetOptions(merge: true));
      }
    }
  }


  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    _showLocalNotification(message);

  
    if (Get.context != null) {
     
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(message.notification?.body ?? ''),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

 await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]); 
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  await Supabase.initialize(
    url: 'https://umufrbjwcwrktdmtlrsw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIssInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVtdWZyYmp3Y3dya3RkbXRscnN3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQyMzg2MDMsImV4cCI6MjA3OTgxNDYwM30.x9JQMdbWw855KCbg3CobF6ouQSQI-gdREAFtHUclw5Y',
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  setupFCM();
  /// 🔥 ADD THIS
  // Get.put(SettingsController());

  runApp(const GynacologistApp());
}

class GynacologistApp extends StatefulWidget {
  const GynacologistApp({super.key});

  @override
  State<GynacologistApp> createState() => _GynacologistAppState();
}

class _GynacologistAppState extends State<GynacologistApp> {
  @override
  void initState() {
    super.initState();
   
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      // behavior: const NoStretchScrollBehavior(),
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      
      child: GetMaterialApp(
        scrollBehavior: const MaterialScrollBehavior().copyWith(
    overscroll: false,
  ),
        debugShowCheckedModeBanner: false,
        title: 'RNS App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue,
          ),
        ),
        initialRoute: AppRoutes.splash,
        getPages: AppRoutes.pages,
      ),
    );
  }
//   @override
// Widget build(BuildContext context) {
//   final settings = Get.find<SettingsController>();

//   return Obx(() {
//     return ScrollConfiguration(
//       behavior: const ScrollBehavior().copyWith(overscroll: false),
//       child: GetMaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'RNS App',

//         /// 🌗 THEMES (FlexColorScheme)
//         theme: FlexThemeData.light(
//           scheme: FlexScheme.blue,
//           useMaterial3: true,
//         ),
//         darkTheme: FlexThemeData.dark(
//           scheme: FlexScheme.blue,
//           useMaterial3: true,
//         ),
//         themeMode:
//             settings.isDark.value ? ThemeMode.dark : ThemeMode.light,

//         /// 🌍 LANGUAGE
//         locale: settings.locale.value,
//         supportedLocales: const [
//           Locale('en'),
//           Locale('hi'),
//           Locale('mr'),
//         ],
//         localizationsDelegates:  [
//           // GlobalMaterialLocalizations.delegate,
//           // GlobalWidgetsLocalizations.delegate,
//           // GlobalCupertinoLocalizations.delegate,
//         ],

//         initialRoute: AppRoutes.splash,
//         getPages: AppRoutes.pages,
//       ),
//     );
//   });
// }

}


class NoStretchScrollBehavior extends ScrollBehavior {
  const NoStretchScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // 👇 This removes BOTH glow & stretch overscroll
    return child;
  }
}