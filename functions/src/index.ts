import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();
const fcm = admin.messaging();

export const sendToTokens = functions.firestore
    .document("userData/{userId}/matches/{matchId}/messages/{messageId}")
    .onCreate(async (snapshot) => {
      const message = snapshot.data();

      const querySnapshot = await db.collection("userData")
          .doc(message.target).collection("tokens").get();

      const tokens = querySnapshot.docs.map((snap) => snap.id);

      const payload: admin.messaging.MessagingPayload = {
        notification: {
          title: "New message from ${message.sender}",
          body: message.message,
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      };
      fcm.sendToDevice(tokens, payload);
    });

