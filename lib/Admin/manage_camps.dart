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
  final _dateStartController = TextEditingController(); // formatted text shown to user
  final _dateEndController = TextEditingController(); 
  final _timeStartController = TextEditingController(); // formatted time shown to user
  final _timeEndController = TextEditingController(); // formatted time shown to user
  final _descriptionController = TextEditingController();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;//instead of just date we should have start date and end date
  TimeOfDay? _selectedStartTimeOfDay;//sart tiem and end time
  TimeOfDay? _selectedEndTimeOfDay;
  //  DateTime? _selectedDate;
  // 

  bool _isLoading = false;

  Future<void> _addCamp() async {
    if (_addressController.text.isEmpty ||
        _dateStartController.text.isEmpty || 
        _dateEndController.text.isEmpty ||
        _timeStartController.text.isEmpty ||
        _timeEndController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address, Date & Time are required')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Store both readable date/time and a timestamp for queries
      final timestampForEvent = DateTime(
        _selectedStartDate!.year,
        _selectedStartDate!.month,
        _selectedStartDate!.day,
        _selectedStartTimeOfDay?.hour ?? 0,
        _selectedStartTimeOfDay?.minute ?? 0,
      );

      final ref = await FirebaseFirestore.instance.collection('camps').add({
        'address': _addressController.text.trim(),
        'startdate': _dateStartController.text.trim(), // readable string
        'enddate': _dateEndController.text.trim(), // readable string
        // 'starttime': _timeStartController.text.trim(), // readable string
        // 'endtime': _timeEndController.text.trim(), // readable string
        // 'startDate': Timestamp.fromDate(_selectedStartDate!),
        // 'endDate': Timestamp.fromDate(_selectedEndDate!),
//         'startTime': {
//   'hour': _selectedStartTimeOfDay!.hour,
//   'minute': _selectedStartTimeOfDay!.minute
// },
// 'endTime': {
//   'hour': _selectedEndTimeOfDay!.hour,
//   'minute': _selectedEndTimeOfDay!.minute
// },
'starttime': _timeStartController.text.trim(), // readable
'endtime': _timeEndController.text.trim(),     // readable

'startTime': {
  'hour': _selectedStartTimeOfDay!.hour,
  'minute': _selectedStartTimeOfDay!.minute,
},
'endTime': {
  'hour': _selectedEndTimeOfDay!.hour,
  'minute': _selectedEndTimeOfDay!.minute,
},


        'eventDateTime': Timestamp.fromDate(timestampForEvent), // for sorting/filtering
        'description': _descriptionController.text.trim(),
        'status': 'active',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Send notification AFTER successful DB write
      // await NotificationService.sendToAllUsers(
      //   title: 'New Health Camp Scheduled!',
      //   // body: '${_dateStartController.text} at ${_timeController.text}\nLocation: ${_addressController.text}',
      //   body: 'From ${_dateStartController.text} to ${_dateEndController.text} \nTime: ${_timeStartController.text} - ${_timeEndController.text}\nLocation: ${_addressController.text}',
        
      //   // type: 'camp',
      // );
    await NotificationService.sendToAllUsers(
  title: 'New Health Camp Scheduled!',
  body:
      'From ${_dateStartController.text} to ${_dateEndController.text}\n'
      'Time: ${_timeStartController.text} - ${_timeEndController.text}\n'
      'Location: ${_addressController.text}',
  type: 'camp',
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
      _dateStartController.clear();
      _dateEndController.clear();
      _timeStartController.clear();
      _timeEndController.clear();
      _descriptionController.clear();
      _selectedStartDate = null;
      _selectedEndDate = null;
      _selectedStartTimeOfDay = null;
      _selectedEndTimeOfDay = null;

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

  Future<void> _pickStartDateForDialog() async {
    final picked = await showDatePicker(
      // barrierColor: Colors.amber,
      
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
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
        _selectedStartDate = picked;
        _dateStartController.text = '${picked.day}/${picked.month}/${picked.year}';

      });
    }
  }
  Future<void> _pickEndDateForDialog() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? DateTime.now(),
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
        _selectedEndDate = picked;
        _dateEndController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _pickStartTimeForDialog() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTimeOfDay ?? TimeOfDay.now(),
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
        _selectedStartTimeOfDay = picked;
        _timeStartController.text = picked.format(context);
      });
    }
  }
  Future<void> _pickEndTimeForDialog() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTimeOfDay ?? TimeOfDay.now(),
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
        _selectedEndTimeOfDay = picked;
        _timeEndController.text = '${picked.format(context)}';
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _dateStartController.dispose();
    _timeStartController.dispose(); // note: this line is fixed below in code block
    _timeEndController.dispose(); 
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Manage Camps'),
        centerTitle: true,
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
                  // title: Text('${data['date']} at ${data['time']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  title: Text('${data['startdate']} to ${data['enddate']} \n${data['starttime']} - ${data['endtime']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['address'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                      if ((data['description'] ?? '').toString().isNotEmpty)
                        Text(data['description'], style: const TextStyle(color: Colors.black87)),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _editCamp(camps[i].reference, data),
                      ),
                   IconButton(

                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCamp(camps[i].reference),
                  ),
                ],
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
    _dateStartController.clear();
    _dateEndController.clear();
    _timeStartController.clear();
    _timeEndController.clear();
    _descriptionController.clear();
    _selectedStartDate = null;
    
    _selectedEndDate = null;
    _selectedStartTimeOfDay = null;
    _selectedEndTimeOfDay = null;

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
              // start date
              CustomTextField(
                model: FormFieldModel(label: "Start Date", hint: "Select start date", required: true, prefixIcon: Icons.calendar_today),
                controller: _dateStartController,
                autofocus: false,
                readOnly: true,
                onTap: _pickStartDateForDialog,
                showClearButton: false,
              ),
              const SizedBox(height: 12),
              // end date
              CustomTextField(
                model: FormFieldModel(label: "End Date", hint: "Select end date", required: true, prefixIcon: Icons.calendar_today),
                controller: _dateEndController,
                autofocus: false,
                readOnly: true,
                onTap: _pickEndDateForDialog,
                showClearButton: false,
              ),
              // CustomTextField(
              //   model: FormFieldModel(label: "Date", hint: "Select date", required: true, prefixIcon: Icons.calendar_today),
              //   controller: _dateController,
              //   autofocus: false,
              //   readOnly: true,
              //  // 
              //   onTap: _pickDateForDialog,
              //   showClearButton: false,
              // ),
              const SizedBox(height: 12),
      CustomTextField(
                model: FormFieldModel(label: "Start Time", hint: "Select start time", required: true, prefixIcon: Icons.access_time),
                controller:   _timeStartController, // <-- keep controller
                readOnly: true,
                onTap: _pickStartTimeForDialog,
                showClearButton: false,
              ),
              const SizedBox(height: 12),
              // End time
              CustomTextField(
                model: FormFieldModel(label: "End Time", hint: "Select end time", required: true, prefixIcon: Icons.access_time),
                controller:   _timeEndController, // <-- keep controller
                readOnly: true,
                onTap: _pickEndTimeForDialog,
                showClearButton: false,
              ),
              // Time Picker -> CustomTextField (readOnly)
              // Start time
              // CustomTextField(
              //   model: FormFieldModel(label: "Start Time", hint: "Select start time", required: true, prefixIcon: Icons.access_time),
              //   controller:   _timeStartController, // <-- keep controller
              //   readOnly: true,
              //   onTap: _pickStartTimeForDialog,
              //   showClearButton: false,
              // ),
              // const SizedBox(height: 12),
              // // End time
              // CustomTextField(
              //   model: FormFieldModel(label: "End Time", hint: "Select end time", required: true, prefixIcon: Icons.access_time),
              //   controller:   _timeEndController, // <-- keep controller
              //   readOnly: true,
              //   onTap: _pickEndTimeForDialog,
              //   showClearButton: false,
              // ),
              // CustomTextField(
              //   model: FormFieldModel(label: "Time", hint: "Select time", required: true, prefixIcon: Icons.access_time),
              //   controller:   _timeController, // <-- keep controller
              //   readOnly: true,
              //   onTap: _pickTimeForDialog,
              //   showClearButton: false,
              // ),
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
// camps should be editable and deletable. Add edit functionality as well.
  Future<void> _editCamp(DocumentReference ref, Map<String, dynamic> existingData) async {
    // Pre-fill controllers with existing data
    _addressController.text = existingData['address'] ?? '';
    _dateStartController.text = existingData['startdate'] ?? '';
    _dateEndController.text = existingData['enddate'] ?? '';
    _timeStartController.text = existingData['starttime'] ?? '';
    _timeEndController.text = existingData['endtime'] ?? '';
    _descriptionController.text = existingData['description'] ?? '';
    await NotificationService.sendToAllUsers(
  title: 'Health Camp Updated',
  body:
      'Updated Camp Schedule\n'
      'From ${_dateStartController.text} to ${_dateEndController.text}\n'
      'Time: ${_timeStartController.text} - ${_timeEndController.text}\n'
      'Location: ${_addressController.text}',
  type: 'camp',
);


    // Show dialog similar to add, but for editing
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Edit Camp'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Same fields as add dialog
              CustomTextField(
                model: FormFieldModel(
                  label: "Address",
                  hint: "Please enter the address",
                  required: true,
                  maxLines: 2,
                  prefixIcon: Icons.location_on,
                ),
                controller: _addressController,
                showClearButton: false,
              ),
              // Other fields...
              const SizedBox(height: 12),
              // Date Picker -> CustomTextField (readOnly)
              // start date
              CustomTextField(
                model: FormFieldModel(label: "Start Date", hint: "Select start date", required: true, prefixIcon: Icons.calendar_today),
                controller: _dateStartController,
                autofocus: false,
                readOnly: true,
                onTap: _pickStartDateForDialog,
                showClearButton: false,
              ),
              const SizedBox(height: 12),
              // end date
              CustomTextField(
                model: FormFieldModel(label: "End Date", hint: "Select end date", required: true, prefixIcon: Icons.calendar_today),
                controller: _dateEndController,
                autofocus: false,
                readOnly: true,
                onTap: _pickEndDateForDialog,
                showClearButton: false,
              ),
              const SizedBox(height: 12),
              // Time Picker -> CustomTextField (readOnly)
              // Start time
              CustomTextField(
                model: FormFieldModel(label: "Start Time", hint: "Select start time", required: true, prefixIcon: Icons.access_time),
                controller:   _timeStartController, // <-- keep controller
                readOnly: true,
                onTap: _pickStartTimeForDialog,
                showClearButton: false,
              ),
              const SizedBox(height: 12),
              // End time
              CustomTextField(
                model: FormFieldModel(label: "End Time", hint: "Select end time", required: true, prefixIcon: Icons.access_time),
                controller:   _timeEndController, // <-- keep controller
                readOnly: true,
                onTap: _pickEndTimeForDialog,
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
            onPressed: () async {
              // Update Firestore document
             await ref.update({
  'address': _addressController.text.trim(),
  'startdate': _dateStartController.text.trim(),
  'enddate': _dateEndController.text.trim(),
  'starttime': _timeStartController.text.trim(),
  'endtime': _timeEndController.text.trim(),
  'description': _descriptionController.text.trim(),
  'updatedAt': FieldValue.serverTimestamp(),
});

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Camp updated')),
              );
              Get.back();
            },
            child: const Text('Update',style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCamp(DocumentReference ref) async {
    await NotificationService.sendToAllUsers(
  title: 'Health Camp Cancelled',
  body: 'A scheduled health camp has been cancelled.',
  type: 'camp',
);

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
