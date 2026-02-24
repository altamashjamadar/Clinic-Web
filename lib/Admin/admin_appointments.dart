
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';
// import 'package:rns_herbals_app/Screens/drawer_screen.dart';
import 'package:rns_herbals_app/model/form_field_model.dart';
import 'package:rns_herbals_app/widgets/custom_text_field.dart';

class AdminAppointments extends StatefulWidget {
  const AdminAppointments({super.key});

  @override
  _AdminAppointmentsState createState() => _AdminAppointmentsState();
}

class _AdminAppointmentsState extends State<AdminAppointments> {
  String _selectedStatus = 'pending';

  Future<void> _approveAppointment(DocumentSnapshot appointment) async {
    final data = appointment.data() as Map<String, dynamic>;
    await appointment.reference.update({
      'status': 'accepted',
      'adminNote': 'Approved',
    });
    print('Approved appointment: ${appointment.id}, data: $data, new status: accepted');
await FirebaseFirestore.instance.collection('notifications').add({
  'userId': data['userId'] ?? 'guest',
  'title': 'Appointment Approved',
  'body': 'Your appointment for ${data['issue'] ?? 'consultation'}'
      '${data['date'] != null ? ' on ${data['date'].toDate()}' : ''}'
      '${data['timeSlot'] != null ? ' at ${data['timeSlot']}' : ''} is confirmed.',
      'Last Menses: ${data['lastMensesDate'] != null ? data['lastMensesDate'].toDate() : 'N/A'}'
      // ' | Cycle Length: ${data['cycleLength'] ?? 'N/A'} days'
  'type': 'appointment',
  'timestamp': FieldValue.serverTimestamp(),
});
    // await FirebaseFirestore.instance.collection('notifications').add({
    //   'userId': data['userId'] ?? 'guest',
    //   'title': 'Appointment Approved',
    //   'body': 'Your appointment for ${data['issue']} on ${data['date'].toDate()} at ${data['timeSlot']} is confirmed.',
    //   'type': 'appointment',
    //   'timestamp': FieldValue.serverTimestamp(),
    // });
    ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('Appointment approved'),
    backgroundColor: Colors.green,
    duration: const Duration(seconds: 5),
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(10),
  ),
);
    //  ScaffoldMessenger.of(context).showSnackBar(
    //   'Success',
    //   'Appointment approved',
    //   backgroundColor: Colors.green,
    //   colorText: Colors.white,
    //   margin: const EdgeInsets.all(10),
    //   duration: const Duration(seconds: 3),
    // );
  }

  Future<void> _rejectAppointment(DocumentSnapshot appointment) async {
    final data = appointment.data() as Map<String, dynamic>;
    final note = await _showNoteDialog(context);
    if (note != null && note!.isNotEmpty) {
      await appointment.reference.update({
        'status': 'rejected',
        'adminNote': note,
      });
      print('Rejected appointment: ${appointment.id}, data: $data, new status: rejected, note: $note');

      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': data['userId'] ?? 'guest',
        'title': 'Appointment Rejected',
        'body': 'Your appointment was rejected: $note',
        'Last Menses: ${data['lastMensesDate'] != null ? data['lastMensesDate'].toDate() : 'N/A'}'
        // ' | Cycle Length: ${data['cycleLength'] ?? 'N/A'} days' 
        'type': 'appointment',
        'timestamp': FieldValue.serverTimestamp(),
      });
       ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
        // context : Text('Success'),
    content: const Text('Appointment rejected'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        // content: const Text('Appointment rejected') ,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
  )
      );
    }
  }

  Future<String?> _showNoteDialog(BuildContext context) async {
    final TextEditingController noteController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Reject Reason *'),
        content: CustomTextField(model: FormFieldModel(label: "Mandatory Description", hint: "Enter description"), controller: noteController,maxLines: 3,),
        // TextField(
        //   controller: noteController,
        //   decoration: const InputDecoration(
        //     labelText: 'Mandatory Description',
        //     border: OutlineInputBorder(),
        //   ),
        //   maxLines: 3,
        // ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',  style: TextStyle(color: Colors.blue),),
          ),
          TextButton(
            onPressed: () {
              final note = noteController.text;
              if (note.isNotEmpty) {
                Navigator.pop(context, note);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Reason is required'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.red,
                    margin: const EdgeInsets.all(10),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text('Reject',style: TextStyle(color: Colors.blue),),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Manage Appointments',style: TextStyle(
          color: Colors.white
        ),),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // drawer: const DrawerScreen(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusCard('pending', Colors.orange),
                _buildStatusCard('accepted', Colors.green),
                _buildStatusCard('rejected', Colors.red),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .where('status', isEqualTo: _selectedStatus.toLowerCase())
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final appointments = snapshot.data?.docs ?? [];
                if (appointments.isEmpty) {
                  return const Center(child: Text('No appointments available.'));
                }
                return ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    final data = appointment.data() as Map<String, dynamic>;
                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(data['name'] ?? 'Unknown'),
                        
subtitle: Column(
  mainAxisAlignment: MainAxisAlignment.start,
  children: [
    Text(
      'Date: ${data['date']?.toDate()?.toString() ?? 'Not specified'}\n'  // Null safe access
      'Time: ${data['timeSlot'] ?? 'Not specified'}\n'
      'Issue: ${data['issue'] ?? ''}\n'
      'Last Menses: ${data['lastMensesDate'] != null ? data['lastMensesDate'].toDate() : 'N/A'}\n'
      'Note: ${data['adminNote'] ?? ''}',
    ),
  ],
),
                        trailing: _selectedStatus.toLowerCase() == 'pending'
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check, color: Colors.green),
                                    onPressed: () => _approveAppointment(appointment),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: () => _rejectAppointment(appointment),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String status, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status.toLowerCase();
        });
      },
      child: Card(
        color: _selectedStatus == status.toLowerCase() ? color : Colors.grey[300],
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Text(
              status,
              style: TextStyle(
                color: _selectedStatus == status.toLowerCase() ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}