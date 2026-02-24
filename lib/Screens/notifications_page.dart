// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class NotificationsPage extends StatelessWidget {
//   const NotificationsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notifications'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       body: user == null
//           ? const Center(child: Text('Please login'))
//           : StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('notifications')
//                   .where('userId', isEqualTo: user.uid)
//                   .orderBy('timestamp', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final docs = snapshot.data!.docs;
//                 if (docs.isEmpty) {
//                   return const Center(child: Text('No notifications'));
//                 }

//                 return ListView.builder(
//                   itemCount: docs.length,
//                   itemBuilder: (context, index) {
//                     final data =
//                         docs[index].data() as Map<String, dynamic>;

//                     return ListTile(
//                       leading: Icon(
//                         data['type'] == 'camp'
//                             ? Icons.event
//                             : Icons.notifications,
//                         color: Colors.blue,
//                       ),
//                       title: Text(data['title']),
//                       subtitle: Text(data['body']),
//                       trailing: data['isRead'] == false
//                           ? const Icon(Icons.circle,
//                               color: Colors.red, size: 10)
//                           : null,
//                       onTap: () {
//                         docs[index].reference.update({'isRead': true});
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//     );
//   }
// }
