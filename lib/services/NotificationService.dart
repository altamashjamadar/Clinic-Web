// // lib/services/notification_service.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationService {
//   static final _messaging = FirebaseMessaging.instance;
//   static final _local = FlutterLocalNotificationsPlugin();

//   static Future<void> sendToAllUsers({
//     required String title,
//     required String body,
//   }) async {
//     final usersSnap = await FirebaseFirestore.instance.collection('users').get();
//     final tokens = usersSnap.docs
//         .map((doc) => doc.data()['fcmToken'] as String?)
//         .where((token) => token != null && token.isNotEmpty)
//         .toList();

//     for (String token in tokens) {
//       await _messaging.sendMessage(to: token, message: {
//         'notification': {'title': title, 'body': body},
//         'data': {'type': 'camp'},
//       });
//     }

//     // Also show local notification for current user
//     await _local.show(
//       0,
//       title,
//       body,
//       const NotificationDetails(
//         android: AndroidNotificationDetails('high_importance_channel', 'Camps'),
//       ),
//     );
//   }
// }

// lib/services/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  static const String _fcmUrl = 'https://fcm.googleapis.com/fcm/send';
  static const String _serverKey = 'YOUR_FCM_SERVER_KEY_HERE'; // Get from Firebase Console > Cloud Messaging

  static Future<void> sendToAllUsers({
    required String title,
    required String body,
  }) async {
    try {
      final usersSnap = await FirebaseFirestore.instance.collection('users').get();
      final List<String> tokens = [];

      for (var doc in usersSnap.docs) {
        final token = doc.data()['fcmToken'] as String?;
        if (token != null && token.isNotEmpty) {
          tokens.add(token);
        }
      }

      if (tokens.isEmpty) return;

      for (String token in tokens) {
        await http.post(
          Uri.parse(_fcmUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'key=$_serverKey',
          },
          body: jsonEncode({
            'to': token,
            'notification': {
              'title': title,
              'body': body,
            },
            'data': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
          }),
        );
      }
    } catch (e) {
      print('FCM Send Error: $e');
    }
  }
}