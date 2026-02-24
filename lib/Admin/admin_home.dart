// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';
// import 'package:rns_herbals_app/Admin/manage_news.dart';
// import 'package:rns_herbals_app/Screens/book_appointment.dart';
// import 'package:rns_herbals_app/Screens/drawer_screen.dart';
// import 'package:rns_herbals_app/model/form_field_model.dart';
// import 'package:rns_herbals_app/widgets/custom_text_field.dart';
// import 'admin_appointments.dart';
// import 'manage_camps.dart';
// import 'manage_products.dart';
// import 'manage_orders.dart';

// class AdminHome extends StatelessWidget {
//   const AdminHome({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(

//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(

//         backgroundColor: Colors.blue,
//         // foregroundColor: Colors.white,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "RNS Clinic Admin",
//           style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
     
//       ),
//       drawer: const DrawerScreen(),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header Greeting
//               Text(
//                 'Welcome back, Admin!',
//                 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue,
//                     ),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 'Here\'s what\'s happening today',
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
//               ),
//               const SizedBox(height: 20),

//               // Appointment Status (kept)
//               _buildAppointmentCard(context),

//               const SizedBox(height: 20),

//               // Quick Actions (kept and redesigned)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Quick Actions',
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//                   ),
//                   // small helper action (optional)
//                   TextButton(
//                     onPressed: () {
//                       // optional: navigate to appointments list
//                       Get.to(() => const AdminAppointments());
//                     },
//                     child: const Text('View All', style: TextStyle(color: Colors.blue)),
//                   )
//                 ],
//               ),
//               const SizedBox(height: 12),
//               _buildQuickActionsGrid(context),

//               const SizedBox(height: 40),
//             ],
//           ),
//         ),
//       ),

//     );
//   }

//   // Reusable Card
//   Widget _card({required String title, required Widget child, EdgeInsets? padding}) {
//     return Container(
//       width: double.infinity,
//       padding: padding ?? const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 6)),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // small title row
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
//             ],
//           ),
//           const SizedBox(height: 12),
//           child,
//         ],
//       ),
//     );
//   }

//   // 1. Appointment Status
//   Widget _buildAppointmentCard(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('appointments').snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return _card(
          
//             title: 'Appointment Status',
            
//             child: const Center(child: SizedBox(height: 48, width: 48, child: CircularProgressIndicator())),
//           );
//         }

//         final docs = snapshot.data!.docs;
//         final pending = docs.where((d) => (d.data() as Map<String, dynamic>)['status'] == 'pending').length;
//         final accepted = docs.where((d) => (d.data() as Map<String, dynamic>)['status'] == 'accepted').length;
//         final rejected = docs.where((d) => (d.data() as Map<String, dynamic>)['status'] == 'rejected').length;

//         return _card(
          
//           title: 'Appointment Status',
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   _statusTile(context, 'Pending', pending, Icons.schedule, Colors.orange),
//                   _statusTile(context, 'Accepted', accepted, Icons.check_circle, Colors.green),
//                   _statusTile(context, 'Rejected', rejected, Icons.cancel, Colors.red),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               // quick appointment actions row
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   OutlinedButton.icon(
//                     onPressed: () => Get.to(() => const AdminAppointments()),
//                     icon: const Icon(Icons.list_alt, size: 18,color: Colors.blue,),
//                     label: const Text('Manage Appointments',style: TextStyle(color: Colors.blue),),
//                     style: OutlinedButton.styleFrom(
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _statusTile(BuildContext context, String label, int count, IconData icon, Color color) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//         margin: const EdgeInsets.symmetric(horizontal: 6),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.06),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 18,
//                   backgroundColor: color.withOpacity(0.12),
//                   child: Icon(icon, size: 18, color: color),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         '$count',
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       Text(
//                         label,
//                         style: TextStyle(fontSize: 11, color: color.withOpacity(0.9)),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildQuickActionsGrid(BuildContext context) {
//     final actions = [
//       {'icon': Icons.schedule, 'label': 'Appointments', 'page': const AdminAppointments()},
//       {'icon': Icons.article, 'label': 'Add News', 'page': const ManageNews()},
//       {'icon': Icons.event, 'label': 'Create Camp', 'page': const ManageCamps()},
//       {'icon': Icons.inventory_2, 'label': 'Manage Products', 'page': const AdminProductManagement()},
//       {'icon': Icons.shopping_bag, 'label': 'View Orders', 'page': const ManageOrders()},

//       //admin should be able to add appointmnets if any user requests from call or eamil
//       {'icon': Icons.add_circle, 'label': 'Add Appointment', 'page': const BookAppointment()},
//     ];

//     return _card(
      
//       title: '',
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
//       child: GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: actions.length,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3,
//           crossAxisSpacing: 12,
//           mainAxisSpacing: 12,
//           childAspectRatio: 0.95,
//         ),
//         itemBuilder: (context, i) {
//           final act = actions[i];
//           return InkWell(
//             onTap: () => Get.to(() => act['page'] as Widget),
//             borderRadius: BorderRadius.circular(12),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.grey.withOpacity(0.08)),
//                 boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 4))],
//               ),
//               padding: const EdgeInsets.all(8),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircleAvatar(
//                     radius: 20,
//                     backgroundColor: const Color.fromARGB(255, 117, 203, 229).withOpacity(0.12),
//                     child: Icon(act['icon'] as IconData, color: Colors.blue),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     act['label'] as String,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

// }

// // class AddAppointment extends StatefulWidget {
// //   const AddAppointment({super.key});

// //   @override
// //   State<AddAppointment> createState() => _AddAppointmentState();
// // }

// // class _AddAppointmentState extends State<AddAppointment> {
// //   final _nameController = TextEditingController();
// //   final _emailController = TextEditingController();
// //   final _phoneController = TextEditingController();
// //   final _issueController = TextEditingController();
// //   String? _selectedTimeSlot;
// //   DateTime? _selectedDate;
// //   DateTime? _selectMensesDate;

// //   List<String> _timeSlots = [];
// //   bool _isLoading = false;
// //   //  final User? _user = FirebaseAuth.instance.currentUser;

// //   @override
// //   void initState() {
// //     super.initState();
// //     // _generateTimeSlots();
// //   }


// //   @override
// //   Widget build(BuildContext context) {  
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(title: const Text('Book Appointment',style: TextStyle(color: Colors.white),),centerTitle: true, backgroundColor: Colors.blue, iconTheme: const IconThemeData(color: Colors.white)),
// //       body: SingleChildScrollView(
// //       //  dragStartBehavior: DragStartBehavior.start,
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           children: [
            
// //             // Card(
// //             //   color: Colors.white,
              
// //             //   elevation: 5,
// //             //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
// //             //   child: Padding(
// //             //     padding: const EdgeInsets.all(16),
// //             //     child: Row(
// //             //       children: [
// //             //         const CircleAvatar(radius: 35, backgroundImage: AssetImage("assets/images/doc_avatar.png")),
// //             //         const SizedBox(width: 16),
// //             //         Expanded(
// //             //           child: Column(
// //             //             crossAxisAlignment: CrossAxisAlignment.start,
// //             //             children: [
// //             //               const Text('Dr. Sana Sayed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
// //             //               Text('Gynecologist', style: TextStyle(color: Colors.grey[700])),
// //             //               Row(children: const [Icon(Icons.star, color: Colors.amber, size: 18), SizedBox(width: 4), Text("4.9 (234)")]),
// //             //             ],
// //             //           ),
// //             //         ),
// //             //       ],
// //             //     ),
// //             //   ),
// //             // ),

// //             const SizedBox(height: 25),

            
// //             CustomTextField(model: FormFieldModel(label: "Name", hint: "Full Name",prefixIcon: Icons.person,required: true), controller: _nameController),
// //             const SizedBox(height: 20),
            
            
// //             CustomTextField(model: FormFieldModel(label: "Email", hint: "Enter your email",prefixIcon: Icons.mail), controller: _emailController),
            
// //             const SizedBox(height: 20),
// //             CustomTextField(model: FormFieldModel(label: "Phone", hint: "Phone Number",keyboardType: TextInputType.phone,prefixIcon: Icons.phone), controller: _phoneController),
            
// //             const SizedBox(height: 20),

            
            
// //             TextFormField(
// //               decoration: _inputDecoration(
// //                 _selectedDate != null ? DateFormat('dd/MM/yyyy').format(_selectedDate!) : 'Select Date',
// //                 Icons.calendar_today,
// //                 required: true,
// //               ),
// //               readOnly: true,
// //               onTap: _pickDate,

// //             ),
// //             const SizedBox(height: 20),

// //             TextFormField(
// //               decoration: _inputDecoration(
// //                 _selectedTimeSlot ?? 'Select Time',
// //                 Icons.access_time,
// //                 required: true,
// //               ),
// //               readOnly: true,
// //               onTap: _showTimeSlotDialog,
// //             ),
// //             const SizedBox(height: 20),
// //             // 
// // // 1. Add last Menses date (optional field)
// //             TextFormField(
// //               decoration: _inputDecoration(
// //                 _selectMensesDate != null ? 'Menses Date: ${DateFormat('dd/MM/yyyy').format(_selectMensesDate!)}' : 'Select Menses Date (Optional)',
// //                 Icons.date_range,
// //               ),
// //               readOnly: true,
// //               onTap: _pickMensesDate,
// //             ),
// //             const SizedBox(height: 20),
// //             CustomTextField(model: FormFieldModel(label: "Issue", hint: "Write your issue"), controller: _issueController, ),
        
// //             const SizedBox(height: 30),

// //             SizedBox(
// //               width: double.infinity,
// //               child: ElevatedButton(
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.blue,
// //                   padding: const EdgeInsets.symmetric(vertical: 16),
// //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //                 ),
// //                 onPressed: _isLoading ? null : _bookAppointment,
// //                 child: _isLoading
// //                     ? const CircularProgressIndicator(color: Colors.white)
// //                     : const Text('Book Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
// //               ),
// //             ),
// //           ],
// //           ),
// //       ),
// //     );
// //   }
// // }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rns_herbals_app/Admin/manage_clinic_settings.dart';
import 'package:rns_herbals_app/Admin/manage_slots.dart';

import 'admin_appointments.dart';
import 'manage_camps.dart';
import 'manage_products.dart';
import 'manage_orders.dart';
import 'manage_news.dart';
import '../Screens/book_appointment.dart';
import '../Screens/drawer_screen.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'RNS Clinic Admin',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: const DrawerScreen(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Greeting
              Text(
                'Welcome back, Admin!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                "Here's what's happening today",
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),

              /// Appointment Status
              _buildAppointmentStatus(),

              const SizedBox(height: 24),

              /// Quick Actions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () => Get.to(() => const AdminAppointments()),
                    icon: const Icon(Icons.arrow_forward_ios, size: 12),
                    label: const Text('View All'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2F6CA8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildQuickActionsGrid(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // COMMON CARD
  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C2F5B).withOpacity(0.10),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }

  // ---------------------------------------------------------
  // APPOINTMENT STATUS CARD
  Widget _buildAppointmentStatus() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('appointments').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _card(
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        final pending =
            docs.where((d) => d['status'] == 'pending').length;
        final accepted =
            docs.where((d) => d['status'] == 'accepted').length;
        final rejected =
            docs.where((d) => d['status'] == 'rejected').length;

        return _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Appointment Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _statusTile(
                    'Pending',
                    pending,
                    Icons.schedule,
                    const Color(0xFFD8A659),
                    const Color(0xFFEAF5EB),
                  ),
                  _statusTile(
                    'Accepted',
                    accepted,
                    Icons.check_circle,
                    const Color(0xFF60A066),
                    const Color(0xFFEAF5EB),
                  ),
                  _statusTile(
                    'Rejected',
                    rejected,
                    Icons.cancel,
                    const Color(0xFFCD6D67),
                    const Color(0xFFFDEDEC),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => Get.to(() => const AdminAppointments()),
                  icon: const Icon(Icons.list_alt, size: 18),
                  label: const Text('Manage Appointments'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _statusTile(
    String label,
    int count,
    IconData icon,
    Color iconColor,
    Color bgColor,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: iconColor.withOpacity(0.15),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 10),
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    color: iconColor.withOpacity(0.9),
                  ),
                ),
            //   ],
            // )
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // QUICK ACTIONS GRID
  Widget _buildQuickActionsGrid() {
    final actions = [
      {'icon': Icons.schedule, 'label': 'Appointments', 'page': const AdminAppointments()},
      {'icon': Icons.article, 'label': 'Add News', 'page': const ManageNews()},
      {'icon': Icons.event, 'label': 'Create Camp', 'page': const ManageCamps()},
      {'icon': Icons.inventory_2, 'label': 'Products', 'page': const AdminProductManagement()},
      {'icon': Icons.shopping_bag, 'label': 'Orders', 'page': const ManageOrders()},
      {'icon': Icons.add_circle, 'label': 'Add Appointment', 'page': const BookAppointment()},
      {
  'icon': Icons.settings,
  'label': 'Clinic Settings',
  'page': const ManageClinicSettings(),
},
{
  'icon': Icons.schedule,
  'label': 'Manage Slots',
  'page': const ManageSlots(),
},

    ];

    return _card(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: actions.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        itemBuilder: (context, i) {
          final act = actions[i];
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Get.to(() => act['page'] as Widget),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF384970).withOpacity(0.10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF384970).withOpacity(0.10),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFF2F6FA),
                    child: Icon(
                      act['icon'] as IconData,
                      color: const Color(0xFF1C2F5B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    act['label'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C2F5B),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
