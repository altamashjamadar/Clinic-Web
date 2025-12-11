// lib/screens/news_detail_page.dart
import 'package:flutter/material.dart';

class NewsDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String date;

  const NewsDetailPage({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('News'),centerTitle: true, backgroundColor: Colors.blue,foregroundColor: Colors.white,),
      body: SingleChildScrollView(
        
        child: Column(
          
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                height: 260,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 260,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                
                Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Published: $date', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                Text(description, style: const TextStyle(fontSize: 16, height: 1.5)),
              ]),
            ),
        ],
        ),
      ),
    );
  }
}
