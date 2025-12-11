// // lib/screens/manage_camps.dart
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';
// import 'package:rns_herbals_app/model/form_field_model.dart';
// import 'package:rns_herbals_app/services/NotificationService.dart';
// import 'package:rns_herbals_app/widgets/custom_text_field.dart';

// class ManageCamps extends StatefulWidget {
//   const ManageCamps({super.key});
//   @override State<ManageCamps> createState() => _ManageCampsState();
// }

// class _ManageCampsState extends State<ManageCamps> {
//   final _addressController = TextEditingController();
//   final _dateController = TextEditingController();
//   final _timeController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   bool _isLoading = false;

//   Future<void> _addCamp() async {
//     await NotificationService.sendToAllUsers(
//   title: 'New Health Camp Scheduled!',
//   body: '$_dateController.text at $_timeController.text\nLocation: $_addressController.text',
// );
//     if (_addressController.text.isEmpty ||
//         _dateController.text.isEmpty ||
//         _timeController.text.isEmpty) {
//       // Get.snackbar('Error', 'Address, Date & Time are required');
//        ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content:  const Text('Address, Date & Time are required')),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);
//     try {
//       await FirebaseFirestore.instance.collection('camps').add({
//         'address': _addressController.text.trim(),
//         'date': _dateController.text.trim(),
//         'time': _timeController.text.trim(),
//         'description': _descriptionController.text.trim(),
//         'status': 'active',
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//  ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content:  const Text('Camp added!'),
//         backgroundColor: Colors.green,
//         behavior: SnackBarBehavior.floating,
//           duration: const Duration(seconds: 5)
//         ),
//       );
//       // Get.snackbar('Success', 'Camp added!', backgroundColor: Colors.green, colorText: Colors.white);
//       _addressController.clear();
//       _dateController.clear();
//       _timeController.clear();
//       _descriptionController.clear();
//     } catch (e) {
//       // Get.snackbar('Error', 'Failed: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content:  Text('Failed to add camp: $e')),
//         );  
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text('Manage Camps'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showAddCampDialog,
//         backgroundColor: Colors.blue,
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('camps')
//             .orderBy('timestamp', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           final camps = snapshot.data?.docs ?? [];
//           if (camps.isEmpty) {
//             return const Center(
//               child: Text('No camps yet\nTap + to add', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey)),
//             );
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(12),
//             itemCount: camps.length,
//             itemBuilder: (context, i) {
//               final data = camps[i].data() as Map<String, dynamic>;
//               return Card(
//                 color: Colors.white,
//                 elevation: 3,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 child: ListTile(
//                   leading: const Icon(Icons.event, color: Colors.red),
//                   title: Text('${data['date']} at ${data['time']}', style: const TextStyle(fontWeight: FontWeight.bold)),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(data['address'], style: const TextStyle(fontWeight: FontWeight.w500)),
//                       if (data['description']?.isNotEmpty == true)
//                         Text(data['description'], style: const TextStyle(color: Colors.black87)),
//                     ],
//                   ),
//                   trailing: IconButton(
//                     icon: const Icon(Icons.delete, color: Colors.red),
//                     onPressed: () => _deleteCamp(camps[i].reference),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   void _showAddCampDialog() {
//     _addressController.clear();
//     _dateController.clear();
//     _timeController.clear();
//     _descriptionController.clear();

//     Get.dialog(
//       AlertDialog(
//         title: const Text('Add New Camp'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Address
//               CustomTextField(model: FormFieldModel(label: "Address", hint: "Please enter your address",required: true,prefixIcon: Icons.location_on), controller: _addressController),
//               // TextField(
//               //   controller: _addressController,
//               //   decoration: const InputDecoration(
//               //     labelText: 'Address *',
//               //     prefixIcon: Icon(Icons.location_on, color: Colors.red),
//               //     border: OutlineInputBorder(),
//               //   ),
//               //   maxLines: 2,
//               // ),
//               const SizedBox(height: 12),

//               // Date Picker
//               TextFormField(
//                 controller: _dateController,
//                 readOnly: true,
//                 decoration: const InputDecoration(
//                   labelText: 'Date *',
//                   prefixIcon: Icon(Icons.calendar_today, color: Colors.blue),
//                   border: OutlineInputBorder(),
//                 ),
//                 onTap: () async {
//                   final picked = await showDatePicker(
//                     context: context,
//                     initialDate: DateTime.now(),
//                     firstDate: DateTime.now(),
//                     lastDate: DateTime(2026),
//                   );
//                   if (picked != null) {
//                     _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
//                   }
//                 },
//               ),
//               const SizedBox(height: 12),

//               // Time Picker
//               TextFormField(
//                 controller: _timeController,
//                 readOnly: true,
//                 decoration: const InputDecoration(
//                   labelText: 'Time *',
//                   prefixIcon: Icon(Icons.access_time, color: Colors.blue),
//                   border: OutlineInputBorder(),
//                 ),
//                 onTap: () async {
//                   final picked = await showTimePicker(
//                     context: context,
//                     initialTime: TimeOfDay.now(),
//                   );
//                   if (picked != null) {
//                     _timeController.text = picked.format(context);
//                   }
//                 },
//               ),
//               const SizedBox(height: 12),

//               // Description (Optional)
//               CustomTextField(model: FormFieldModel(label: "Description (Optional)", hint: "Additional details",prefixIcon: Icons.description,maxLines: 3), controller: _descriptionController),
//               // TextField(
//               //   controller: _descriptionController,
//               //   decoration: const InputDecoration(
//               //     labelText: 'Description (Optional)',
//               //     border: OutlineInputBorder(),
//               //   ),
//               //   maxLines: 3,
//               // ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: _isLoading ? null : () {
//               _addCamp();
//               Get.back();
//             },
//             child: _isLoading
//                 ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
//                 : const Text('Add'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _deleteCamp(DocumentReference ref) async {
//     final confirm = await Get.dialog(
//       AlertDialog(
//         backgroundColor: Colors.white,
//         title: const Text('Delete Camp'),
//         content: const Text('This cannot be undone.'),
//         actions: [
//           TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
//           ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('Delete')),
//         ],
//       ),
//     );
//     if (confirm == true) {
//       await ref.delete();
//       // Get.snackbar('Deleted', 'Camp removed');
//        ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content:  const Text('Camp removed')),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _addressController.dispose();
//     _dateController.dispose();
//     _timeController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }
// }\\


// lib/screens/manage_camps.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rns_herbals_app/model/form_field_model.dart';
import 'package:rns_herbals_app/services/NotificationService.dart';
import 'package:rns_herbals_app/widgets/custom_text_field.dart';

class ManageCamps extends StatefulWidget {
  const ManageCamps({super.key});
  @override
  State<ManageCamps> createState() => _ManageCampsState();
}

class _ManageCampsState extends State<ManageCamps> {
  final _addressController = TextEditingController();
  final _dateController = TextEditingController(); // formatted text shown to user
  final _timeController = TextEditingController(); // formatted time shown to user
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTimeOfDay;

  bool _isLoading = false;

  Future<void> _addCamp() async {
    if (_addressController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address, Date & Time are required')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Store both readable date/time and a timestamp for queries
      final timestampForEvent = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTimeOfDay?.hour ?? 0,
        _selectedTimeOfDay?.minute ?? 0,
      );

      final ref = await FirebaseFirestore.instance.collection('camps').add({
        'address': _addressController.text.trim(),
        'date': _dateController.text.trim(), // readable string
        'time': _timeController.text.trim(), // readable string
        'eventDateTime': Timestamp.fromDate(timestampForEvent), // for sorting/filtering
        'description': _descriptionController.text.trim(),
        'status': 'active',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Send notification AFTER successful DB write
      await NotificationService.sendToAllUsers(
        title: 'New Health Camp Scheduled!',
        body: '${_dateController.text} at ${_timeController.text}\nLocation: ${_addressController.text}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camp added!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );

      // clear fields only after success
      _addressController.clear();
      _dateController.clear();
      _timeController.clear();
      _descriptionController.clear();
      _selectedDate = null;
      _selectedTimeOfDay = null;

      // close dialog if it is open
      if (Get.isDialogOpen ?? false) Get.back();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add camp: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDateForDialog() async {
    final picked = await showDatePicker(
      // barrierColor: Colors.amber,
      
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _pickTimeForDialog() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTimeOfDay ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTimeOfDay = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _dateController.dispose();
    _timeController?.dispose(); // note: this line is fixed below in code block
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Manage Camps'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCampDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('camps')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final camps = snapshot.data?.docs ?? [];
          if (camps.isEmpty) {
            return const Center(
              child: Text('No camps yet\nTap + to add',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: camps.length,
            itemBuilder: (context, i) {
              final data = camps[i].data() as Map<String, dynamic>;
              return Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.event, color: Colors.blue),
                  title: Text('${data['date']} at ${data['time']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['address'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                      if ((data['description'] ?? '').toString().isNotEmpty)
                        Text(data['description'], style: const TextStyle(color: Colors.black87)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCamp(camps[i].reference),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddCampDialog() {
    _addressController.clear();
    _dateController.clear();
    _timeController.clear();
    _descriptionController.clear();
    _selectedDate = null;
    _selectedTimeOfDay = null;

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Add New Camp'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                model: FormFieldModel(
                  label: "Address",
                  hint: "Please enter the address",
                  required: true,
                  maxLines: 2,
                  prefixIcon: Icons.location_on,
                ),
                controller: _addressController,
                showClearButton: false, // hide clear icon for dialog fields
              ),
              const SizedBox(height: 12),

              // Date Picker -> CustomTextField (readOnly)
              CustomTextField(
                model: FormFieldModel(label: "Date", hint: "Select date", required: true, prefixIcon: Icons.calendar_today),
                controller: _dateController,
                autofocus: false,
                readOnly: true,
               // 
                onTap: _pickDateForDialog,
                showClearButton: false,
              ),
              const SizedBox(height: 12),

              // Time Picker -> CustomTextField (readOnly)
              CustomTextField(
                model: FormFieldModel(label: "Time", hint: "Select time", required: true, prefixIcon: Icons.access_time),
                controller:   _timeController, // <-- keep controller
                readOnly: true,
                onTap: _pickTimeForDialog,
                showClearButton: false,
              ),
              const SizedBox(height: 12),

              CustomTextField(
                model: FormFieldModel(label: "Description (Optional)", hint: "Additional details", prefixIcon: Icons.description, maxLines: 3),
                controller: _descriptionController,
                maxLines: 3,
                showClearButton: false,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel',style: TextStyle(color: Colors.blue),)),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
            ),
            onPressed: _isLoading ? null : () async {
              await _addCamp();
            },
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Add',style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCamp(DocumentReference ref) async {
    final confirm = await Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete Camp'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel',style: TextStyle(color: Colors.blue),)),
          ElevatedButton(style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.red),
          ), onPressed: () => Get.back(result: true), child: const Text('Delete',
          style: TextStyle(
            color: Colors.white
          ),)),
        ],
      ),
    );
    if (confirm == true) {
      await ref.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camp removed')),
      );
    }
  }
}
