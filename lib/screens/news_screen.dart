import 'package:clinic_web/widgets/Responsive_Wrapper.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
// import 'package:rns_herbals_app/Screens/full_image_viewer.dart';
// import 'news_detail_page.dart'; 
class NewsPage extends StatelessWidget {
  const NewsPage({super.key});
  //  void _openFullImage(BuildContext context, String imageUrl) {
  // Navigator.push(
  //   context,
  //   // MaterialPageRoute(
  //   //   // builder: (_) => FullImageViewer(imageUrl: imageUrl),
  //   // ),
  // );
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('News'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ResponsiveWrapper(
        child: SafeArea(
          child: Center(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('news')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
            
                final news = snapshot.data?.docs ?? [];
                if (news.isEmpty) {
                  return const Center(
            
                    child: Column(
                      
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.article_outlined, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No news available', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  );
                }
            
                return NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (OverscrollIndicatorNotification notification) {
                    notification.disallowIndicator();
                    return true;
                  },
                  child: ListView.builder(
                    physics: const ClampingScrollPhysics(),    
                    padding: const EdgeInsets.all(12),
                    itemCount: news.length,
                    itemBuilder: (context, index) {
                      final doc = news[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final date = data['timestamp'] != null
                          ? DateFormat('dd MMM yyyy').format((data['timestamp'] as Timestamp).toDate())
                          : 'Unknown date';
                      final title = (data['title'] ?? '').toString();
                      final desc = (data['description'] ?? '').toString();
                      final img = (data['imageUrl'] ?? '').toString();
                  
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _openNewsSheet(context, title, desc, img, date),
                  
                        child: Card(
                          color: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (img.isNotEmpty)
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: Image.network(
                                    img,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Container(
                                        height: 180,
                                        color: Colors.grey[200],
                                        child: const Center(child: CircularProgressIndicator()),
                                      );
                                    },
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 180,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                   
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title.isNotEmpty ? title : 'No Title',
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            desc,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Published: $date',
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                  
                                   
                                    const SizedBox(width: 8),
                                    const Icon(Icons.chevron_right, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _openNewsSheet(BuildContext context, String title, String description, String imageUrl, String date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.38,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: ScrollConfiguration(
                  behavior: ScrollBehavior().copyWith(overscroll: false),
                child: SingleChildScrollView(
                  controller: controller,
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                     
                      const SizedBox(height: 12),
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 12),
                
                      if (imageUrl.isNotEmpty)
                        GestureDetector(
                          // onTap: () => _openFullImage(context, imageUrl),
                
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
                            child: Image.network(
                              imageUrl,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 220,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title.isNotEmpty ? title : 'No Title', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Published: $date', style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 12),
                            Text(description, style: const TextStyle(fontSize: 16, height: 1.5)),
                            const SizedBox(height: 20),
                
                           
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop(); 
                                    // Navigator.of(context).push(MaterialPageRoute(builder: (_) => NewsDetailPage(title: title, description: description, imageUrl: imageUrl, date: date)));
                                  },
                                  icon: const Icon(Icons.open_in_new,color: Colors.white,),
                                  label: const Text('View Full Page',style: TextStyle(color: Colors.white),),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                ),
                                const SizedBox(width: 12),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Close',style: TextStyle(color: Colors.blue),),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
   

  }
}
