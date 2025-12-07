const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();
const statsRef = db.collection('metrics').doc('stats');

// 1. New User → Increase totalPatients & newPatients (today)
exports.updatePatientCount = functions.auth.user().onCreate(async (user) => {
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const batch = db.batch();

  // Increment total
  batch.set(statsRef, { totalPatients: admin.firestore.FieldValue.increment(1) }, { merge: true });

  // Increment new today
  batch.set(statsRef, { newPatients: admin.firestore.FieldValue.increment(1) }, { merge: true });

  // Reset newPatients at midnight
  const tomorrow = new Date(today);
  tomorrow.setDate(tomorrow.getDate() + 1);
  const resetTime = admin.firestore.Timestamp.fromDate(tomorrow);

  // Schedule reset
  await db.collection('triggers').doc('resetNewPatients').set({
    runAt: resetTime,
  });

  await batch.commit();
});

// 2. Reset newPatients daily at 00:00
exports.resetNewPatients = functions.pubsub.schedule('0 0 * * *').onRun(async () => {
  await statsRef.update({ newPatients: 0 });
});

// 3. Order placed → Update revenue
exports.updateRevenue = functions.firestore
  .document('orders/{orderId}')
  .onCreate(async (snap) => {
    const data = snap.data();
    const total = data.totalPrice || 0;

    await statsRef.set({
      revenue: admin.firestore.FieldValue.increment(total)
    }, { merge: true });
  });