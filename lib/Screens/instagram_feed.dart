import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InstagramFeed extends StatefulWidget {
  const InstagramFeed({super.key});

  @override
  _InstagramFeedState createState() => _InstagramFeedState();
}

class _InstagramFeedState extends State<InstagramFeed> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(
            Uri.parse('https://www.instagram.com/dratiyasana/embed'),
          ); // Replace with your clinic's username
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Instagram Feed'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: WebViewWidget(controller: controller
        ),
      ),
    );
  }
}
