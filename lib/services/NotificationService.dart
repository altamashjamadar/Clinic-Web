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