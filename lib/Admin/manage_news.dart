import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rns_herbals_app/model/form_field_model.dart';
import 'package:rns_herbals_app/widgets/custom_text_field.dart';
import '../services/SupabaseService.dart';

class ManageNews extends StatefulWidget {
  const ManageNews({super.key});

  @override
  State<ManageNews> createState() => _ManageNewsState();
}

class _ManageNewsState extends State<ManageNews> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;

  // ================= ADD NEWS =================

  void _showAddNewsDialog() {
    _titleController.clear();
    _descriptionController.clear();
    _imageFile = null;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Add News'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    model: FormFieldModel(
                      label: "Title",
                      required: true,
                      hint: "Enter title",
                    ),
                    controller: _titleController,
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    model: FormFieldModel(
                      label: "Description",
                      required: true,
                      maxLines: 4,
                      hint: "Enter description",
                    ),
                    controller: _descriptionController,
                  ),
                  const SizedBox(height: 16),

                  if (_imageFile == null)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () async {
                        final picked = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setDialogState(() {
                            _imageFile = File(picked.path);
                          });
                        }
                      },
                      icon: const Icon(Icons.photo, color: Colors.white),
                      label: const Text(
                        'Pick Image',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  else
                    Column(
                      children: [
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 300,
                          height: 150,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setDialogState(() {
                              _imageFile = null;
                            });
                          },
                          child: const Text('Remove Image'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.blue)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: _isLoading ? null : _addNews,
                child:
                    const Text('Add', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addNews() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and description required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl = '';
      if (_imageFile != null) {
        imageUrl = await SupabaseService.uploadImage(
          image: _imageFile!,
          bucket: 'news',
          folder: 'posts',
        );
      }

      await FirebaseFirestore.instance.collection('news').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Get.back();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('News added'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ================= EDIT NEWS =================

  void _showEditNewsDialog(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    _titleController.text = data['title'] ?? '';
    _descriptionController.text = data['description'] ?? '';
    _imageFile = null;
    String imageUrl = data['imageUrl'] ?? '';

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Edit News'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  CustomTextField(
                    model: FormFieldModel(label: "Title", required: true, hint: ''),
                    controller: _titleController,
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    model: FormFieldModel(
                        label: "Description",
                        required: true,
                        maxLines: 4, hint: ''),
                    controller: _descriptionController,
                  ),
                  const SizedBox(height: 16),

                  if (imageUrl.isNotEmpty && _imageFile == null)
                    Column(
                      children: [
                        SizedBox(
                          width: 300,
                          height: 150,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setDialogState(() {
                              imageUrl = '';
                            });
                          },
                          child: const Text('Remove Image'),
                        ),
                      ],
                    ),

                  if (_imageFile != null)
                    Column(
                      children: [
                        SizedBox(
                          width: 300,
                          height: 150,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setDialogState(() {
                              _imageFile = null;
                            });
                          },
                          child: const Text('Remove Image'),
                        ),
                      ],
                    ),

                  if (imageUrl.isEmpty && _imageFile == null)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () async {
                        final picked = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setDialogState(() {
                            _imageFile = File(picked.path);
                          });
                        }
                      },
                      icon: const Icon(Icons.photo, color: Colors.white),
                      label: const Text(
                        'Pick Image',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.blue)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () =>
                    _updateNews(doc.id, imageUrl),
                child: const Text('Update',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateNews(String id, String oldImageUrl) async {
    String? imageUrl = oldImageUrl;

    if (_imageFile != null) {
      imageUrl = await SupabaseService.uploadImage(
        image: _imageFile!,
        bucket: 'news',
        folder: 'posts',
      );
      if (oldImageUrl.isNotEmpty) {
        await SupabaseService.deleteFileByUrl(oldImageUrl);
      }
    }

    await FirebaseFirestore.instance.collection('news').doc(id).update({
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'imageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    Get.back();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Manage News'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _showAddNewsDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
       body: StreamBuilder<QuerySnapshot>(
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
              child: Text(
                'No news yet\nTap + to add',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
             physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: news.length,
            itemBuilder: (context, index) {
              final doc = news[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data['imageUrl'] != null && data['imageUrl'].isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          data['imageUrl'],
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 180,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error, size: 50),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['title'] ?? 'No Title',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data['description'] ?? '',
                            style: const TextStyle(color: Colors.black87),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                               IconButton(
      icon: const Icon(Icons.edit, color: Colors.orange),
      onPressed: () => _showEditNewsDialog(doc),
    ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteNews(doc.id, data['imageUrl']),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  
}

  Future<void> _deleteNews(String id, String? imageUrl) async {
    final confirm = await Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete News'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel',style: TextStyle(color: Colors.blue),)),
          ElevatedButton(onPressed: () => Get.back(result: true),style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.red),
          ), child: const Text('Delete',style: TextStyle(
            color: Colors.white
          ),)),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('news').doc(id).delete();
        if (imageUrl != null && imageUrl.isNotEmpty) {
          await SupabaseService.deleteFileByUrl(imageUrl);
        }
      
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content:  const Text('News deleted')),
          );
      } catch (e) {
       
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content:  Text('Delete failed: $e')),
          );
      }
    }
  }


}



// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:rns_herbals_app/model/form_field_model.dart';
// import 'package:rns_herbals_app/widgets/custom_text_field.dart';
// import '../services/SupabaseService.dart';

// class ManageNews extends StatefulWidget {
//   const ManageNews({super.key});

//   @override
//   State<ManageNews> createState() => _ManageNewsState();
// }

// class _ManageNewsState extends State<ManageNews> {
//   final _titleController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   File? _imageFile;
//   bool _isLoading = false;
//   Future<void> _updateNews(String id, String oldImageUrl) async {
//   if (_titleController.text.trim().isEmpty ||
//       _descriptionController.text.trim().isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Title and description required')),
//     );
//     return;
//   }

//   setState(() => _isLoading = true);

//   try {
//     String? imageUrl = oldImageUrl;

//     // New image selected → upload + delete old
//     if (_imageFile != null) {
//       imageUrl = await SupabaseService.uploadImage(
//         image: _imageFile!,
//         bucket: 'news',
//         folder: 'posts',
//       );

//       if (oldImageUrl.isNotEmpty) {
//         await SupabaseService.deleteFileByUrl(oldImageUrl);
//       }
//     }

//     // Image removed
//     if (_imageFile == null && oldImageUrl.isEmpty) {
//       imageUrl = '';
//     }

//     await FirebaseFirestore.instance.collection('news').doc(id).update({
//       'title': _titleController.text.trim(),
//       'description': _descriptionController.text.trim(),
//       'imageUrl': imageUrl,
//       'updatedAt': FieldValue.serverTimestamp(),
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('News updated'),
//         backgroundColor: Colors.green,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );

//     Get.back();
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Update failed: $e')),
//     );
//   } finally {
//     setState(() => _isLoading = false);
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text('Manage News'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showAddNewsDialog,
//         backgroundColor: Colors.blue,
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
    //   body: StreamBuilder<QuerySnapshot>(
    //     stream: FirebaseFirestore.instance
    //         .collection('news')
    //         .orderBy('timestamp', descending: true)
    //         .snapshots(),
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.waiting) {
    //         return const Center(child: CircularProgressIndicator());
    //       }
    //       if (snapshot.hasError) {
    //         return Center(child: Text('Error: ${snapshot.error}'));
    //       }

    //       final news = snapshot.data?.docs ?? [];
    //       if (news.isEmpty) {
    //         return const Center(
    //           child: Text(
    //             'No news yet\nTap + to add',
    //             textAlign: TextAlign.center,
    //             style: TextStyle(fontSize: 18, color: Colors.grey),
    //           ),
    //         );
    //       }

    //       return ListView.builder(
    //          physics: const ClampingScrollPhysics(),
    //         padding: const EdgeInsets.all(12),
    //         itemCount: news.length,
    //         itemBuilder: (context, index) {
    //           final doc = news[index];
    //           final data = doc.data() as Map<String, dynamic>;

    //           return Card(
    //             color: Colors.white,
    //             elevation: 3,
    //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 if (data['imageUrl'] != null && data['imageUrl'].isNotEmpty)
    //                   ClipRRect(
    //                     borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
    //                     child: Image.network(
    //                       data['imageUrl'],
    //                       height: 180,
    //                       width: double.infinity,
    //                       fit: BoxFit.cover,
    //                       errorBuilder: (_, __, ___) => Container(
    //                         height: 180,
    //                         color: Colors.grey[300],
    //                         child: const Icon(Icons.error, size: 50),
    //                       ),
    //                     ),
    //                   ),
    //                 Padding(
    //                   padding: const EdgeInsets.all(16),
    //                   child: Column(
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     children: [
    //                       Text(
    //                         data['title'] ?? 'No Title',
    //                         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    //                       ),
    //                       const SizedBox(height: 8),
    //                       Text(
    //                         data['description'] ?? '',
    //                         style: const TextStyle(color: Colors.black87),
    //                       ),
    //                       const SizedBox(height: 12),
    //                       Row(
    //                         mainAxisAlignment: MainAxisAlignment.end,
    //                         children: [
    //                            IconButton(
    //   icon: const Icon(Icons.edit, color: Colors.orange),
    //   onPressed: () => _showEditNewsDialog(doc),
    // ),
    //                           IconButton(
    //                             icon: const Icon(Icons.delete, color: Colors.red),
    //                             onPressed: () => _deleteNews(doc.id, data['imageUrl']),
    //                           ),
    //                         ],
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           );
    //         },
    //       );
    //     },
    //   ),
    // );
//   }

//   void _showAddNewsDialog() {
//   _titleController.clear();
//   _descriptionController.clear();
//   _imageFile = null;

//   Get.dialog(
//     StatefulBuilder(
//       builder: (context, setDialogState) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           title: const Text('Add News'),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CustomTextField(
//                   model: FormFieldModel(
//                     label: "Title",
//                     hint: "Enter title",
//                     required: true,
//                   ),
//                   controller: _titleController,
//                 ),
//                 const SizedBox(height: 12),

//                 CustomTextField(
//                   model: FormFieldModel(
//                     label: "Description",
//                     hint: "Enter description",
//                     maxLines: 4,
//                     required: true,
//                   ),
//                   controller: _descriptionController,
//                 ),
//                 const SizedBox(height: 16),

//                 // IMAGE PREVIEW / PICK
//                 if (_imageFile == null)
//                   ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                     ),
//                     onPressed: () async {
//                       final picked = await ImagePicker()
//                           .pickImage(source: ImageSource.gallery, imageQuality: 80);
//                       if (picked != null) {
//                         setDialogState(() {
//                           _imageFile = File(picked.path);
//                         });
//                       }
//                     },
//                     icon: const Icon(Icons.photo, color: Colors.white),
//                     label: const Text(
//                       'Pick Image',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   )
//                 else
//                   Column(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: Image.file(
//                           _imageFile!,
//                           height: 150,
//                           width: double.infinity,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           setDialogState(() {
//                             _imageFile = null;
//                           });
//                         },
//                         child: const Text('Remove Image'),
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Get.back(),
//               child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//               onPressed: _isLoading
//                   ? null
//                   : () async {
//                       await _addNews();
//                     },
//               child: const Text('Add', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         );
//       },
//     ),
//   );
// }


//   Future<void> _pickImage() async {
//     final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
//     if (picked != null) {
//       setState(() => _imageFile = File(picked.patha));
     
//     }
//   }

//   Future<void> _addNews() async {
//     if (_titleController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) {
//       // Get.snackbar('Error', 'Title and description required');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content:  const Text('Title and description required')),
//         );
//       return;
//     }

//     setState(() => _isLoading = true);
//     try {
//       String? imageUrl;
//       if (_imageFile != null) {
//         imageUrl = await SupabaseService.uploadImage(
//   image: _imageFile!,
//   bucket: 'news',
//   folder: 'posts',
// );
//        print('Image URL from Supabase: $imageUrl');
//     }

//       await FirebaseFirestore.instance.collection('news').add({
//         'title': _titleController.text.trim(),
//         'description': _descriptionController.text.trim(),
//         'imageUrl': imageUrl ?? '',
//         'timestamp': FieldValue.serverTimestamp(),
//       });

//         // clear state
//     _titleController.clear();
//     _descriptionController.clear();
//     setState(() => _imageFile = null);

   
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content:  const Text('News added!'), 
//       behavior: SnackBarBehavior.floating,
//         backgroundColor: Colors.green, ),);
//     Get.back(); // close dialog
//     } catch (e) {
//        print('Add news failed: $e');
//       // Get.snackbar('Error', 'Failed: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content:  Text('Failed to add news: $e')),
//         );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//  void _showEditNewsDialog(DocumentSnapshot doc) {
//   final data = doc.data() as Map<String, dynamic>;

//   _titleController.text = data['title'] ?? '';
//   _descriptionController.text = data['description'] ?? '';
//   _imageFile = null;

//   String imageUrl = data['imageUrl'] ?? '';

//   Get.dialog(
//     StatefulBuilder(
//       builder: (context, setDialogState) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           title: const Text('Edit News'),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CustomTextField(
//                   model: FormFieldModel(label: "Title", required: true, hint: ''),
//                   controller: _titleController,
//                 ),
//                 const SizedBox(height: 12),

//                 CustomTextField(
//                   model: FormFieldModel(
//                     label: "Description",
//                     maxLines: 4,
//                     required: true, hint: '',
//                   ),
//                   controller: _descriptionController,
//                 ),
//                 const SizedBox(height: 16),

//                 // EXISTING IMAGE
//                 if (imageUrl.isNotEmpty && _imageFile == null)
//                   Column(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: Image.network(
//                           imageUrl,
//                           height: 150,
//                           width: double.infinity,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           setDialogState(() {
//                             imageUrl = '';
//                           });
//                         },
//                         child: const Text('Remove Image'),
//                       ),
//                     ],
//                   ),

//                 // NEW IMAGE
//                 if (_imageFile != null)
//                   Column(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: Image.file(
//                           _imageFile!,
//                           height: 150,
//                           width: double.infinity,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           setDialogState(() {
//                             _imageFile = null;
//                           });
//                         },
//                         child: const Text('Remove Image'),
//                       ),
//                     ],
//                   ),

//                 if (imageUrl.isEmpty && _imageFile == null)
//                   ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//                     onPressed: () async {
//                       final picked = await ImagePicker()
//                           .pickImage(source: ImageSource.gallery, imageQuality: 80);
//                       if (picked != null) {
//                         setDialogState(() {
//                           _imageFile = File(picked.path);
//                         });
//                       }
//                     },
//                     icon: const Icon(Icons.photo, color: Colors.white),
//                     label: const Text('Pick Image',
//                         style: TextStyle(color: Colors.white)),
//                   ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Get.back(),
//               child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//               onPressed: () => _updateNews(doc.id, imageUrl),
//               child: const Text('Update', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         );
//       },
//     ),
//   );
// }


  

//   Future<void> _deleteNews(String id, String? imageUrl) async {
//     final confirm = await Get.dialog(
//       AlertDialog(
//         backgroundColor: Colors.white,
//         title: const Text('Delete News'),
//         content: const Text('This cannot be undone.'),
//         actions: [
//           TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel',style: TextStyle(color: Colors.blue),)),
//           ElevatedButton(onPressed: () => Get.back(result: true),style: ButtonStyle(
//             backgroundColor: MaterialStateProperty.all(Colors.red),
//           ), child: const Text('Delete',style: TextStyle(
//             color: Colors.white
//           ),)),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       try {
//         await FirebaseFirestore.instance.collection('news').doc(id).delete();
//         if (imageUrl != null && imageUrl.isNotEmpty) {
//           await SupabaseService.deleteFileByUrl(imageUrl);
//         }
//         // Get.snackbar('Success', 'News deleted');
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content:  const Text('News deleted')),
//           );
//       } catch (e) {
//         // Get.snackbar('Error', 'Delete failed');
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content:  Text('Delete failed: $e')),
//           );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
 
//   }
// }


