
// lib/screens/book_appointment.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
  List<String> _timeSlots = [];
  bool _isLoading = false;

  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _generateTimeSlots();
  }
void _generateTimeSlots() {
  _timeSlots = List.generate(35, (i) {
    final h = 9 + (i ~/ 3);
    final m = (i % 3) * 20;
    final endM = m + 20 > 59 ? 0 : m + 20;
    final endH = m + 20 > 59 ? h + 1 : h;

    final startH = h.toString().padLeft(2, '0');
    final startM = m.toString().padLeft(2, '0');
    final endHStr = endH.toString().padLeft(2, '0');
    final endMStr = endM.toString().padLeft(2, '0');

    return '$startH:$startM - $endHStr:$endMStr';
  }).where((s) => int.parse(s.split('-')[0].split(':')[0]) < 17).toList();
}
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
        
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),//1 prebooking if 1 momth
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {

        _selectedDate = picked;
        _selectedTimeSlot = null;
      });
    }
  }

  Future<void> _showTimeSlotDialog() async {
    if (_selectedDate == null) {
      Get.snackbar('Error', 'Please select a date first');
      return;
    }

    // Get booked slots
    final bookedSnap = await FirebaseFirestore.instance
        .collection('appointments')
        .where('date', isEqualTo: Timestamp.fromDate(_selectedDate!))
        .get();

    final bookedSlots = bookedSnap.docs
        .where((d) => ['pending', 'accepted'].contains(d['status']))
        .map((d) => d['timeSlot'])
        .toSet();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Select Time Slot'),
          content: SizedBox(
            
            width: double.maxFinite,
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: _timeSlots.map((slot) {
                final isBooked = bookedSlots.contains(slot);
                return ChoiceChip(
                  label: Text(slot),
                  selected: _selectedTimeSlot == slot,
                  onSelected: isBooked ? null : (_) {
                    setState(() => _selectedTimeSlot = slot);
                    Navigator.pop(ctx);
                  },
                  backgroundColor: isBooked ? Colors.grey[300] : null,
                  selectedColor: Colors.blue[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: isBooked ? Colors.red : Colors.grey),
                  ),
                );
              }).toList(),
            ),
          ),

          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ],
        );
      },
    );
  }

  Future<void> _bookAppointment() async {
  if (_user == null) {
    Get.to(() => const LoginScreen());
    return;
  }

  if (_nameController.text.isEmpty || _issueController.text.isEmpty || _selectedDate == null || _selectedTimeSlot == null) {
    Get.snackbar('Error', 'Fill all fields and select date & time');
    return;
  }

  setState(() => _isLoading = true);
  try {
    await FirebaseFirestore.instance.collection('appointments').add({
      'userId': _user!.uid,
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'issue': _issueController.text.trim(),
      'date': Timestamp.fromDate(_selectedDate!),
      'timeSlot': _selectedTimeSlot,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // SUCCESS: Show snackbar & clear form
    Get.snackbar(
      'Success',
      'Appointment booked! Waiting for approval.',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );

    // CLEAR ALL FIELDS
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _issueController.clear();
    setState(() {
      _selectedDate = null;
      _selectedTimeSlot = null;
    });

    // Optional: Scroll to top or stay
    // Get.back(); // Remove if you want to stay on screen
  } catch (e) {
    Get.snackbar('Error', 'Failed: $e');
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
      appBar: AppBar(title: const Text('Book Appointment',style: TextStyle(color: Colors.white),), backgroundColor: Colors.blue, iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(
       dragStartBehavior: DragStartBehavior.start,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Doctor Info
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

            // Form Fields
            TextField(controller: _nameController, decoration: _inputDecoration("Name", Icons.person, required: true)),
            const SizedBox(height: 20),
            TextField(controller: _emailController, decoration: _inputDecoration("Email", Icons.email)),
            const SizedBox(height: 20),
            TextField(controller: _phoneController, decoration: _inputDecoration("Phone", Icons.phone)),
            const SizedBox(height: 20),

            // Date & Time Fields (Small, like current date)
            TextFormField(
              decoration: _inputDecoration(
                _selectedDate != null ? DateFormat('dd/MM/yyyy').format(_selectedDate!) : 'Select Date',
                Icons.calendar_today,
                required: true,
              ),
              readOnly: true,
              onTap: _pickDate,
            ),
            const SizedBox(height: 20),

            TextFormField(
              decoration: _inputDecoration(
                _selectedTimeSlot ?? 'Select Time',
                Icons.access_time,
                required: true,
              ),
              readOnly: true,
              onTap: _showTimeSlotDialog,
            ),
            const SizedBox(height: 20),

            TextField(controller: _issueController, decoration: _inputDecoration("Issue", Icons.description, required: true), maxLines: 3),
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
                    TextButton(onPressed: () => Get.to(() => const LoginScreen()), child: const Text('Login Now')),
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

      // Bottom Tab Bar (Same as HomePage)
      // bottomNavigationBar: BottomNavigationBar(
      //   selectedItemColor: Colors.blue,
      //   unselectedItemColor: Colors.grey,
      //   currentIndex: 1,
      //   onTap: (i) {
      //     if (i == 0) Get.offAllNamed('/home');
      //     if (i == 2) Get.toNamed('/instagram');
      //   },
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      //     BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Appointments'),
      //     BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Instagram'),
      //   ],
      // ),
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