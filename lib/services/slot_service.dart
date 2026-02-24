// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:intl/intl.dart';

// // class SlotService {
// //   static int timeToMinutes(String time) {
// //     final p = time.split(':');
// //     return int.parse(p[0]) * 60 + int.parse(p[1]);
// //   }

// //   // ---------------- DELETE FUTURE SLOTS ----------------
// //   static Future<void> deleteFutureSlots() async {
// //     final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

// //     final snap = await FirebaseFirestore.instance
// //         .collection('clinic_slots')
// //         .where('date', isGreaterThanOrEqualTo: today)
// //         .get();

// //     final batch = FirebaseFirestore.instance.batch();
// //     for (var doc in snap.docs) {
// //       batch.delete(doc.reference);
// //     }
// //     await batch.commit();
// //   }

// //   // ---------------- GENERATE SLOTS ----------------
// //   static Future<void> generateSlotsForNextDays(int days) async {
// //     final settings = await FirebaseFirestore.instance
// //         .collection('clinic_settings')
// //         .doc('main')
// //         .get();

// //     final data = settings.data()!;
// //     final start = data['startTime'];
// //     final end = data['endTime'];
// //     final duration = data['slotDuration'];
// //     final capacity = data['defaultSlotCapacity'];

// //     final today = DateTime.now();
// //     final batch = FirebaseFirestore.instance.batch();
// //     int opCount = 0;

// //     for (int d = 0; d < days; d++) {
// //       final date = today.add(Duration(days: d));
// //       DateTime cursor = DateTime(
// //         date.year,
// //         date.month,
// //         date.day,
// //         int.parse(start.split(':')[0]),
// //         int.parse(start.split(':')[1]),
// //       );

// //       final endTime = DateTime(
// //         date.year,
// //         date.month,
// //         date.day,
// //         int.parse(end.split(':')[0]),
// //         int.parse(end.split(':')[1]),
// //       );

// //       while (cursor.isBefore(endTime)) {
// //         final next = cursor.add(Duration(minutes: duration));
// //         final id =
// //             '${DateFormat('yyyy-MM-dd').format(date)}_${DateFormat('HH:mm').format(cursor)}';

// //         final ref =
// //             FirebaseFirestore.instance.collection('clinic_slots').doc(id);

// //         batch.set(ref, {
// //           'date': DateFormat('yyyy-MM-dd').format(date),
// //           'startTime': DateFormat('HH:mm').format(cursor),
// //           'endTime': DateFormat('HH:mm').format(next),
// //           'capacity': capacity,
// //           'booked': 0,
// //           'blocked': false,
// //         });

// //         cursor = next;
// //         opCount++;

// //         if (opCount == 400) {
// //           await batch.commit();
// //           opCount = 0;
// //         }
// //       }
// //     }

// //     if (opCount > 0) {
// //       await batch.commit();
// //     }
// //   }

// //   // ---------------- REALLOCATE APPOINTMENTS ----------------
// //   static Future<void> reallocateAppointments() async {
// //     final now = DateTime.now();

// //     final appts = await FirebaseFirestore.instance
// //         .collection('appointments')
// //         .where('date', isGreaterThan: Timestamp.fromDate(now))
// //         .where('status', whereIn: ['pending', 'accepted'])
// //         .get();

// //     for (var appt in appts.docs) {
// //       final data = appt.data();
// //       final date = (data['date'] as Timestamp).toDate();
// //       final oldStart = data['timeSlot'].split('-')[0].trim();
// //       final oldMin = timeToMinutes(oldStart);
// //       final dateStr = DateFormat('yyyy-MM-dd').format(date);

// //       final slots = await FirebaseFirestore.instance
// //           .collection('clinic_slots')
// //           .where('date', isEqualTo: dateStr)
// //           .where('blocked', isEqualTo: false)
// //           .get();

// //       QueryDocumentSnapshot? nearest;
// //       int minDiff = 99999;

// //       for (var slot in slots.docs) {
// //         final startMin = timeToMinutes(slot['startTime']);
// //         final diff = (startMin - oldMin).abs();

// //         if (diff < minDiff && slot['booked'] < slot['capacity']) {
// //           minDiff = diff;
// //           nearest = slot;
// //         }
// //       }

// //       if (nearest == null) {
// //         await appt.reference.update({
// //           'status': 'reschedule_required',
// //         });
// //         continue;
// //       }

// //       await FirebaseFirestore.instance.runTransaction((tx) async {
// //         tx.update(nearest!.reference, {
// //           'booked': FieldValue.increment(1),
// //         });

// //         tx.update(appt.reference, {
// //           'slotId': nearest.id,
// //           'timeSlot':
// //               '${nearest['startTime']} - ${nearest['endTime']}',
// //           'status': 'pending',
// //           'autoRescheduled': true,
// //         });
// //       });
// //     }
// //   }

// //   // ---------------- MAIN ENTRY ----------------
// //   static Future<void> applyClinicSettingsChange() async {
// //     await deleteFutureSlots();
// //     await generateSlotsForNextDays(30);
// //     await reallocateAppointments();
// //   }
// // }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// class SlotService {
//   static Future<void> applyClinicSettingsChange() async {
//     final db = FirebaseFirestore.instance;

//     // 1️⃣ Read clinic settings
//     final settings =
//         await db.collection('clinic_settings').doc('main').get();

//     final start = settings['startTime']; // "09:00"
//     final end = settings['endTime'];     // "17:00"
//     final duration = settings['slotDuration']; // 20

//     // 2️⃣ Delete ALL future unbooked slots
//     final today = DateTime.now();
//     final snap = await db
//         .collection('clinic_slots')
//         .where('booked', isEqualTo: false)
//         .get();

//     final batch = db.batch();

//     for (final d in snap.docs) {
//       final slotDate =
//           DateFormat('yyyy-MM-dd').parse(d['date']);
//       if (slotDate.isAfter(today)) {
//         batch.delete(d.reference);
//       }
//     }

//     await batch.commit();

//     // 3️⃣ Generate slots for next 30 days
//     for (int i = 0; i < 30; i++) {
//       final day = today.add(Duration(days: i));
//       await _generateSlotsForDay(
//         day: day,
//         start: start,
//         end: end,
//         duration: duration,
//       );
//     }
//   }

//   static Future<void> _generateSlotsForDay({
//     required DateTime day,
//     required String start,
//     required String end,
//     required int duration,
//   }) async {
//     final db = FirebaseFirestore.instance;

//     DateTime cursor = DateTime(
//       day.year,
//       day.month,
//       day.day,
//       int.parse(start.split(':')[0]),
//       int.parse(start.split(':')[1]),
//     );

//     final endTime = DateTime(
//       day.year,
//       day.month,
//       day.day,
//       int.parse(end.split(':')[0]),
//       int.parse(end.split(':')[1]),
//     );

//     while (cursor.isBefore(endTime)) {
//       final next = cursor.add(Duration(minutes: duration));
//       final id =
//           '${DateFormat('yyyy-MM-dd').format(day)}_${DateFormat('HH:mm').format(cursor)}';

//       await db.collection('clinic_slots').doc(id).set({
//         'date': DateFormat('yyyy-MM-dd').format(day),
//         'startTime': DateFormat('HH:mm').format(cursor),
//         'endTime': DateFormat('HH:mm').format(next),
//         'booked': false,
//         'blocked': false,
//       });

//       cursor = next;
//     }
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SlotService {
  static const int DAYS_AHEAD = 30; // 🔒 1 MONTH ONLY

  static Future<void> applyClinicSettingsChange() async {
    final db = FirebaseFirestore.instance;

    // 1️⃣ Read clinic settings
    final settings =
        await db.collection('clinic_settings').doc('main').get();

    final start = settings['startTime']; // "09:00"
    final end = settings['endTime'];     // "17:00"
    final duration = settings['slotDuration']; // 20

    final today = DateTime.now();
    final lastAllowedDate = today.add(const Duration(days: DAYS_AHEAD));

    // 2️⃣ DELETE future unbooked slots (within next 30 days only)
    final snap = await db
        .collection('clinic_slots')
        .where('booked', isEqualTo: false)
        .get();

    final batch = db.batch();

    for (final doc in snap.docs) {
      final slotDate =
          DateFormat('yyyy-MM-dd').parse(doc['date']);

      if (slotDate.isAfter(today) &&
          slotDate.isBefore(lastAllowedDate)) {
        batch.delete(doc.reference);
      }
    }

    await batch.commit();

    // 3️⃣ RE-GENERATE slots for next 30 days
    for (int i = 0; i < DAYS_AHEAD; i++) {
      final day = today.add(Duration(days: i));
      await _generateSlotsForDay(
        day: day,
        start: start,
        end: end,
        duration: duration,
      );
    }
  }

  static Future<void> _generateSlotsForDay({
    required DateTime day,
    required String start,
    required String end,
    required int duration,
  }) async {
    final db = FirebaseFirestore.instance;

    DateTime cursor = DateTime(
      day.year,
      day.month,
      day.day,
      int.parse(start.split(':')[0]),
      int.parse(start.split(':')[1]),
    );

    final endTime = DateTime(
      day.year,
      day.month,
      day.day,
      int.parse(end.split(':')[0]),
      int.parse(end.split(':')[1]),
    );

    while (cursor.isBefore(endTime)) {
      final next = cursor.add(Duration(minutes: duration));
      final id =
          '${DateFormat('yyyy-MM-dd').format(day)}_${DateFormat('HH:mm').format(cursor)}';

      final ref = db.collection('clinic_slots').doc(id);

      // 🔒 Do not overwrite existing slots (important)
      final exists = await ref.get();
      if (!exists.exists) {
        await ref.set({
          'date': DateFormat('yyyy-MM-dd').format(day),
          'startTime': DateFormat('HH:mm').format(cursor),
          'endTime': DateFormat('HH:mm').format(next),
          'booked': false,
          'blocked': false,
        });
      }

      cursor = next;
    }
  }
}
