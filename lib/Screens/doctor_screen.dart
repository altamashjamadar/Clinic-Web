import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rns_herbals_app/Screens/drawer_screen.dart';
import 'package:table_calendar/table_calendar.dart';

class DoctorScreen extends StatelessWidget {
  const DoctorScreen({super.key});
//daily appointment visible to doctor fetched from firebase
Widget buildLegend() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        _Legend(color: Colors.yellowAccent, label: '1-4'),
        _Legend(color: Colors.yellow, label: '5-9'),
        _Legend(color: Colors.orange, label: '10-14'),
        _Legend(color: Colors.red, label: '15+'),
      ],
    ),
  );
}
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(

        title: const Text('Doctor Dashboard',style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Get.offAllNamed('/login');
             
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // //  i want doctor shoyld able to see daily appointment schedule
            Container(
              height: 500,
              child: Expanded(child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SlotCalendar(),
              )),
            ),
      
            // const Text('Welcome, Doctor!', style: TextStyle(fontSize: 24)),
            // const Text('Manage patients, appointments, etc. here.'),
      buildLegend(),    ],
          
          
        ),
      ),
     drawer: const DrawerScreen(),
      bottomNavigationBar: BottomNavigationBar( backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home,), label: 'Dashboard',backgroundColor: Colors.blue),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Profile'),
          // BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Appointments'),
        ],
        currentIndex: 0,
        onTap: (index) {
         Get.toNamed('/profile');
        },
      ),
    );
  }

  
}
class SlotCalendar extends StatefulWidget {
  const SlotCalendar({super.key});

  @override
  State<SlotCalendar> createState() => _SlotCalendarState();
}

class _SlotCalendarState extends State<SlotCalendar> {
  DateTime focusedDay = DateTime.now();
  Map<DateTime, int> bookedSlots = {};
  bool isLoading = true;

  DateTime normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  Color getColor(int slots) {
    if (slots >= 15) return Colors.red;
    if (slots >= 10) return Colors.orange;
    if (slots >= 5) return Colors.yellow;
    if (slots >= 1) return Colors.yellow.shade200;
    return Colors.white;
  }

  @override
  void initState() {
    super.initState();
    loadCounts();
  }

  Future<void> loadCounts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('status', isEqualTo: 'accepted')
        .get();

    final Map<DateTime, int> counts = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['date'] != null) {
        final date = normalize((data['date'] as Timestamp).toDate());
        counts[date] = (counts[date] ?? 0) + 1;
      }
    }

    setState(() {
      bookedSlots = counts;
      isLoading = false;
    });
  }

  // Widget buildDay(DateTime day) {
  //   final slots = bookedSlots[normalize(day)] ?? 0;

  //   return Container(
  //     margin: const EdgeInsets.all(6),
  //     decoration: BoxDecoration(
  //       color: getColor(slots),
  //       borderRadius: BorderRadius.circular(8),
  //       border: Border.all(color: Colors.grey.shade300),
  //     ),
  //     alignment: Alignment.center,
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Text('${day.day}', style: const TextStyle(fontWeight: FontWeight.bold)),
  //         if (slots > 0)
  //           Text(
  //             '$slots',
  //             style: const TextStyle(fontSize: 12),
  //           ),
  //       ],
  //     ),
  //   );
  // }
  Widget buildDay(DateTime day) {
  final slots = bookedSlots[normalize(day)] ?? 0;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    margin: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: getColor(slots),
      borderRadius: BorderRadius.circular(12),
      boxShadow: slots > 0
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ]
          : [],
    ),
    alignment: Alignment.center,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${day.day}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: slots >= 10 ? Colors.white : Colors.black,
          ),
        ),
        if (slots > 0)
          Text(
            '$slots',
            style: TextStyle(
              fontSize: 11,
              color: slots >= 10 ? Colors.white70 : Colors.black54,
            ),
          ),
      ],
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,

      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },

      onPageChanged: (day) {
        focusedDay = day;
      },

      onDaySelected: (selectedDay, _) {
        Get.to(() => DoctorDaySchedule(date: selectedDay));
      },

      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, _) => buildDay(day),
        todayBuilder: (context, day, _) => buildDay(day),
        outsideBuilder: (context, day, _) => buildDay(day),
      ),
    );
  }
}
class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

class DoctorDaySchedule extends StatelessWidget {
  final DateTime date;
  const DoctorDaySchedule({super.key, required this.date});

  DateTime normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final start = normalize(date);
    final end = start.add(const Duration(days: 1));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Appointments - ${date.day}/${date.month}/${date.year}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('status', isEqualTo: 'accepted')
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
            .where('date', isLessThan: Timestamp.fromDate(end))
            .snapshots(),
       builder: (context, snapshot) {
  // 1️⃣ Loading (only FIRST time)
  if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(child: CircularProgressIndicator());
  }

  // 2️⃣ Error state (index / permission / etc.)
  if (snapshot.hasError) {
    return Center(
      child: Text(
        'Something went wrong.\n${snapshot.error}',
        textAlign: TextAlign.center,
      ),
    );
  }

  // 3️⃣ No data case
  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
    return const Center(child: Text('No appointments'));
  }

  // 4️⃣ Success
  final docs = snapshot.data!.docs;

  return ListView.builder(

      physics: const ClampingScrollPhysics(),
    itemCount: docs.length,
    itemBuilder: (context, index) {
      final data = docs[index].data() as Map<String, dynamic>;
      return Card(
        color: Colors.white,
        shadowColor: Colors.grey,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          
          leading: const CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Text(
            data['name'] ?? 'Unknown',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '🕒 ${data['timeSlot']}\nIssue: ${data['issue'] ?? ''}\n'
               'Last Menses: ${data['lastMensesDate'] != null ? data['lastMensesDate'].toDate() : 'N/A'}',
            ),
          ),

        ),
      
      );
    },
  );
},


//           final docs = snapshot.data!.docs;
//           if (docs.isEmpty) {
//             return const Center(child: Text('No appointments'));
//           }

//           return ListView.builder(
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final data = docs[index].data() as Map<String, dynamic>;
//               return Card(
//   margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//   child: ListTile(
//     leading: const CircleAvatar(
//       backgroundColor: Colors.blue,
//       child: Icon(Icons.person, color: Colors.white),
//     ),
//     title: Text(
//       data['name'] ?? 'Unknown',
//       style: const TextStyle(fontWeight: FontWeight.bold),
//     ),
//     subtitle: Padding(
//       padding: const EdgeInsets.only(top: 4),
//       child: Text(
//         '🕒 ${data['timeSlot']}\n ${data['issue'] ?? ''}',
//       ),
//     ),
//   ),
// );

//             },
//           );
        // },
      ),
    );
  }
}
