const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

/* ---------------- PUSH NOTIFICATION ---------------- */

exports.sendPushNotification = functions.firestore
  .document('notifications/{id}')
  .onCreate(async (snap) => {
    const data = snap.data();
    const userId = data.userId;

    if (!userId) return null;

    const userDoc = await admin
      .firestore()
      .collection('users')
      .doc(userId)
      .get();

    const token = userDoc.data()?.fcmToken;
    if(!token) return null;

    await admin.messaging().send({
      token: token,
      notification: {
        title: data.title,
        body: data.body,
      },
      data: {
        type: data.type || 'general',
      },
    });

    return null;
  });

/* ---------------- EMAIL NOTIFICATION ---------------- */

const transporter = nodemailer.createTransport({
  service: 'gmail',
 auth: {
    user: functions.config().email.user,
    pass: functions.config().email.pass,
  },
});

exports.sendEmailOnNotification = functions.firestore
  .document('notifications/{id}')
  .onCreate(async (snap) => {
    const data = snap.data();

    // Only send email for important notifications
    if (!['appointment', 'camp', 'news'].includes(data.type)) return null;

    const userDoc = await admin
      .firestore()
      .collection('users')
      .doc(data.userId)
      .get();

    const email = userDoc.data()?.email;
    if (!email) return null;

    await transporter.sendMail({
      from: 'RNS Herbals <no-reply@rns-herbals.com>',
      to: email,
      subject: data.title,
      html: `
        <h3>${data.title}</h3>
        <p>${data.body}</p>
        <hr/>
        <p>Thank you,<br/>RNS Herbals Team</p>
      `,
    });

    return null;
  });
