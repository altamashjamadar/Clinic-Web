
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rns_herbals_app/model/form_field_model.dart';
import 'package:rns_herbals_app/widgets/custom_text_field.dart';
import 'login_screen.dart';

class BookAppointment extends StatefulWidget {
  const BookAppointment({super.key});
  @override State<BookAppointment> createState() => _BookAppointmentState();
}

class _BookAppointmentState extends State<BookAppointment> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _issueController = TextEditingController();
  String? _selectedTimeSlot;
  DateTime? _selectedDate;
  DateTime? _selectMensesDate;
  String? _selectedSlotId;


  List<String> _timeSlots = [];
  bool _isLoading = false;

  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // _generateTimeSlots();

    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (_user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _nameController.text = data['fullName'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phoneNumber'] ?? '';
      });
    }else{
      setState(() {
        _nameController.text = _user!.displayName ?? '';
        _emailController.text = _user!.email ?? '';
      });
    }
  }
// void _generateTimeSlots() {
//   _timeSlots = List.generate(35, (i) {
//     final h = 9 + (i ~/ 3);
//     final m = (i % 3) * 20;
//     final endM = m + 20 > 59 ? 0 : m + 20;
//     final endH = m + 20 > 59 ? h + 1 : h;

//     final startH = h.toString().padLeft(2, '0');
//     final startM = m.toString().padLeft(2, '0');
//     final endHStr = endH.toString().padLeft(2, '0');
//     final endMStr = endM.toString().padLeft(2, '0');

//     return '$startH:$startM - $endHStr:$endMStr';
//   }).where((s) => int.parse(s.split('-')[0].split(':')[0]) < 17).toList();
// }
Future<void> _showTimeSlotDialog() async {
  if (_selectedDate == null) return;

  final day = DateFormat('yyyy-MM-dd').format(_selectedDate!);

  final snap = await FirebaseFirestore.instance
      .collection('clinic_slots')
      .where('date', isEqualTo: day)
      .where('blocked', isEqualTo: false)
      .get();

  final slots = snap.docs.where((d) => d['booked'] == false).toList();
  if (slots.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('No slots available for this date')),
  );
  return;
}

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Select Slot'),
      content: Wrap(
        spacing: 8,
        children: slots.map((d) {
          final label = '${d['startTime']} - ${d['endTime']}';
          return ChoiceChip(
  label: Text(label),
  selected: _selectedSlotId == d.id,
  selectedColor: Colors.blue.shade100,
  onSelected: (_) {
    setState(() {
      _selectedTimeSlot = label;
      _selectedSlotId = d.id;
    });
    Navigator.pop(context);
  },
);
        }).toList(),
      ),
    ),
  );
}


//i wnat to add a date picker for optional date for menses date
Future<void> _pickMensesDate() async {
    final picked = await showDatePicker(
        
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)), //past 1 year
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectMensesDate) {
      setState(() {

        _selectMensesDate = picked;
      });
    }
  }
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
        
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),//1 prebooking if 1 momth
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {

        _selectedDate = picked;
        _selectedTimeSlot = null;
        _selectedSlotId = null;

      });
    }
  }

  // Future<void> _showTimeSlotDialog() async {
  //   if (_selectedDate == null) {
    
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content:  Text('Please select a date first')),
  //     );
  //     return;
  //   }

    
  //   final bookedSnap = await FirebaseFirestore.instance
  //       .collection('appointments')
  //       .where('date', isEqualTo: Timestamp.fromDate(_selectedDate!))
  //       .get();

  //   final bookedSlots = bookedSnap.docs
  //       .where((d) => ['pending', 'accepted'].contains(d['status']))
  //       .map((d) => d['timeSlot'])
  //       .toSet();

  //   await showDialog(
  //     context: context,
  //     builder: (ctx) {
  //       return AlertDialog(

  //         backgroundColor: Colors.white,
  //         title: const Text('Select Time Slot'),
  //         content: SizedBox(
            
  //           width: double.maxFinite,
  //           child: Wrap(
  //             spacing: 8, runSpacing: 8,
  //             children: _timeSlots.map((slot) {
  //               final isBooked = bookedSlots.contains(slot);
  //               return ChoiceChip(
  //                 label: Text(slot),
  //                 selected: _selectedTimeSlot == slot,
  //                 onSelected: isBooked ? null : (_) {
  //                   setState(() => _selectedTimeSlot = slot);
  //                   Navigator.pop(ctx);
  //                 },
  //                 backgroundColor: isBooked ? Colors.red : Colors.white,
  //                 // color: Colors.white,
  //                 selectedColor: Colors.blue[100],
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(10),
  //                   side: BorderSide(color: isBooked ? Colors.red : Colors.grey),
  //                 ),
  //               );
  //             }).toList(),
  //           ),
  //         ),
          
  //         actions: [
  //           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel',style: TextStyle(color: Colors.blue),)),
  //         ],
  //       );
  //     },
  //   );
  // }

Future<void> _bookAppointment() async {
  if (_user == null) {
    Get.to(() => const LoginScreen());
    return;
  }

  if (_nameController.text.isEmpty ||
      _issueController.text.isEmpty ||
      _selectedDate == null ||
      _selectedTimeSlot == null ||
      _selectedSlotId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fill all fields and select date & time')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final slotRef = FirebaseFirestore.instance
          .collection('clinic_slots')
          .doc(_selectedSlotId);

      final slotSnap = await transaction.get(slotRef);

      if (!slotSnap.exists) {
        throw 'Slot not found';
      }

      final data = slotSnap.data() as Map<String, dynamic>;

      if (data['blocked'] == true) {
        throw 'Slot already booked';
      }

      // if (data['booked'] >= data['capacity']) {
      //   throw 'Slot is already full';
      // }

      // 1️⃣ Increase booked count
      transaction.update(slotRef, {
        'booked': true,
      });

      // 2️⃣ Create appointment
      final appointmentRef =
          FirebaseFirestore.instance.collection('appointments').doc();

      transaction.set(appointmentRef, {
        'userId': _user!.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'issue': _issueController.text.trim(),
        'date': Timestamp.fromDate(_selectedDate!),
        'mensesDate': _selectMensesDate != null
            ? Timestamp.fromDate(_selectMensesDate!)
            : null,
        'timeSlot': _selectedTimeSlot,
        'slotId': _selectedSlotId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
    });

    // ✅ SUCCESS UI
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appointment booked! Waiting for approval.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );

    // ✅ CLEAR FORM
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _issueController.clear();

    setState(() {
      _selectedDate = null;
      _selectMensesDate = null;
      _selectedTimeSlot = null;
      _selectedSlotId = null;
    });

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}

 InputDecoration _inputDecoration(String label, IconData icon, {bool required = false}) {
  return InputDecoration(
    labelText: required ? "$label *" : label,
    labelStyle: const TextStyle(color: Colors.grey), // Default: grey
    floatingLabelStyle: const TextStyle(color: Colors.blue), // On focus: blue
    prefixIcon: Icon(icon, color: Colors.blue),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.blue, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey, width: 1),
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Book Appointment',style: TextStyle(color: Colors.white),),centerTitle: true, backgroundColor: Colors.blue, iconTheme: const IconThemeData(color: Colors.white)),
      body: ScrollConfiguration(
        behavior: ScrollBehavior().copyWith(overscroll: false),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
         dragStartBehavior: DragStartBehavior.start,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              
              Card(
                color: Colors.white,
                
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 35, backgroundImage: AssetImage("assets/images/doc_avatar.png")),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Dr. Sana Sayed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text('Gynecologist', style: TextStyle(color: Colors.grey[700])),
                            Row(children: const [Icon(Icons.star, color: Colors.amber, size: 18), SizedBox(width: 4), Text("4.9 (234)")]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        
              const SizedBox(height: 25),
        
              
              CustomTextField(model: FormFieldModel(label: "Name", hint: "Full Name",prefixIcon: Icons.person,required: true), controller: _nameController),
              const SizedBox(height: 20),
              
              
              CustomTextField(model: FormFieldModel(label: "Email", hint: "Enter your email",prefixIcon: Icons.mail,required: true), controller: _emailController),
              
              const SizedBox(height: 20),
              CustomTextField(model: FormFieldModel(label: "Phone", hint: "Phone Number",keyboardType: TextInputType.phone,prefixIcon: Icons.phone), controller: _phoneController),
              
              const SizedBox(height: 20),
        
             CustomTextField(model: FormFieldModel(label: "Date", hint: "Select Date",prefixIcon: Icons.calendar_today,required: true), controller: TextEditingController(
                text: _selectedDate != null ? DateFormat('dd/MM/yyyy').format(_selectedDate!) : '',
              ), readOnly: true,
              onTap: _pickDate,
             ),
              const SizedBox(height: 20),

             CustomTextField(
  model: FormFieldModel(
    label: "Time",
    hint: "Select time slot",
    required: true,
    prefixIcon: Icons.access_time,
  ),
  controller: TextEditingController(
    text: _selectedTimeSlot ?? '',
  ),
  readOnly: true,
  onTap: () {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date first')),
      );
      return;
    }
    _showTimeSlotDialog();
  },
),

              // TextFormField(
              //   decoration: _inputDecoration(
              //     _selectedDate != null ? DateFormat('dd/MM/yyyy').format(_selectedDate!) : 'Select Date',
              //     Icons.calendar_today,
              //     required: true,
              //   ),
              //   readOnly: true,
              //   onTap: _pickDate,
        
              // // ), onTap: _pickDate,
              // ),
              const SizedBox(height: 20),
        // CustomTextField(model: FormFieldModel(label: "Time", hint: "Select time slot" ,required: true,prefixIcon: Icons.access_time), controller:
        // TextEditingController(
        //         text: _selectedTimeSlot ?? '',
        //       ), readOnly: true,
        //       onTap: _showTimeSlotDialog,
        // ),
              // TextFormField(
              //   decoration: _inputDecoration(
              //     _selectedTimeSlot ?? 'Select Time',
              //     Icons.access_time,
              //     required: true,
              //   ),
              //   readOnly: true,
              //   onTap: _showTimeSlotDialog,
              // ),
              const SizedBox(height: 20),
              // 
        // 1. Add last Menses date (optional field)
        CustomTextField(model: FormFieldModel(label: "Menses Date", readOnly: true, hint: "Select Menses Date (Optional)",prefixIcon: Icons.date_range), controller: 
        TextEditingController(
                text: _selectMensesDate != null ? DateFormat('dd/MM/yyyy').format(_selectMensesDate!) : '',
        ),
        onTap: _pickMensesDate,
        ),
             
              const SizedBox(height: 20),
              CustomTextField(model: FormFieldModel(label: "Issue", hint: "Write your issue" ,required: true,prefixIcon: Icons.description), controller: _issueController,maxLines: 3, ),
          
              const SizedBox(height: 30),
        
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _bookAppointment,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Book Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
        
              const SizedBox(height: 30),
        
              // Appointment History
              const Text('Your Appointments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
        
              if (_user == null)
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.lock_outline, size: 48, color: Colors.grey),
                      const Text('Login to see your appointments'),
                      TextButton(onPressed: () => Get.to(() => const LoginScreen()), child: const Text('Login Now',style: TextStyle(color: Colors.blue),)),
                    ],
                  ),
                )
              else
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('appointments')
                      .where('userId', isEqualTo: _user!.uid)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) return const Center(child: Text('No appointments yet'));
        
                    return ListView.builder(
                      
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final data = docs[i].data() as Map;
                        final date = (data['date'] as Timestamp).toDate();
                        final status = data['status'] ?? 'pending';
                        final color = status == 'accepted' ? Colors.green : status == 'rejected' ? Colors.red : Colors.orange;
        
                        return Card(
                          color: Colors.white,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color.withOpacity(0.1),
                              child: Icon(status == 'accepted' ? Icons.check : status == 'rejected' ? Icons.close : Icons.schedule, color: color),
                            ),
                            title: Text('${DateFormat('dd MMM yyyy').format(date)} • ${data['timeSlot']}'),
                            subtitle: Text('Status: ${status.toUpperCase()}\n${data['issue']}'),
                            isThreeLine: true,
                          ),
                        );
                      },
                    );
                  }, 
                ),
            ],
          ),
        ),
      ),

    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _issueController.dispose();
    super.dispose();
  }
}