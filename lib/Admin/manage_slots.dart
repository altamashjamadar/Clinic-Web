import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ManageSlots extends StatefulWidget {
  const ManageSlots({super.key});

  @override
  State<ManageSlots> createState() => _ManageSlotsState();
}

class _ManageSlotsState extends State<ManageSlots> {
  DateTime selectedDate = DateTime.now();

  Future<void> generateSlots() async {
    final settings = await FirebaseFirestore.instance
        .collection('clinic_settings')
        .doc('main')
        .get();

    final start = settings['startTime'];
    final end = settings['endTime'];
    final duration = settings['slotDuration'];
    // final capacity = settings['defaultSlotCapacity'];

    DateTime cursor = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      int.parse(start.split(':')[0]),
      int.parse(start.split(':')[1]),
    );

    final endTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      int.parse(end.split(':')[0]),
      int.parse(end.split(':')[1]),
    );

    while (cursor.isBefore(endTime)) {
      final next = cursor.add(Duration(minutes: duration));
      final id =
          '${DateFormat('yyyy-MM-dd').format(selectedDate)}_${DateFormat('HH:mm').format(cursor)}';

      await FirebaseFirestore.instance
          .collection('clinic_slots')
          .doc(id)
          .set({
        'date': DateFormat('yyyy-MM-dd').format(selectedDate),
        'startTime': DateFormat('HH:mm').format(cursor),
        'endTime': DateFormat('HH:mm').format(next),
        // 'capacity': capacity,
        // 'booked': 0,
        'blocked': false,
      });

      cursor = next;
    }
  }

  @override
  Widget build(BuildContext context) {
    final day = DateFormat('yyyy-MM-dd').format(selectedDate);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Slots')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: generateSlots,
            child: const Text('Generate Slots for Day'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('clinic_slots')
                  .where('date', isEqualTo: day)
                  .snapshots(),
              builder: (_, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                return ListView(
                  children: snap.data!.docs.map((d) {
                    return SwitchListTile(
                      title: Text('${d['startTime']} - ${d['endTime']}'),
                      // subtitle: Text('Booked ${d['booked']} '),
                      value: !d['blocked'],
                      onChanged: (v) {
                        d.reference.update({'blocked': !v});
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
