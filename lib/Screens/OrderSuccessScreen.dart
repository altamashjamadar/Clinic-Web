import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderSuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 100, color: Colors.green),
            SizedBox(height: 16),
            Text('Order Placed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Thank you for shopping'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.offAllNamed('/home'),
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

