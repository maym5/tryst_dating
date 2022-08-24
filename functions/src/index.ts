import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();
const fcm = admin.messaging();

export const sendChat = functions.firestore
    .document("userData/{userId}/matches/{matchId}/messages/{messageId}")
    .onCreate(async (snapshot, context) => {
      const message = snapshot.data();
      if (context.params.userId == message.target) {
        const querySnapshot = await db.collection("userData")
            .doc(message.target).collection("tokens").get();

        const targetSnapshot = await db.collection("userData")
            .doc(message.target).get();

        const targetData = targetSnapshot?.data();

        const tokens = querySnapshot.docs.map((snap) => snap.id);

        const payload: admin.messaging.MessagingPayload = {
          notification: {
            title: targetData?.name,
            body: message.message,
            clickAction: "FLUTTER_NOTIFICATION_CLICK",
          },
        };
        fcm.sendToDevice(tokens, payload);
      }
    });

export const newDate = functions.firestore
    .document("userData/{userId}/matches/{matchId}")
    .onCreate(async (snapshot, context) => {
      const date = snapshot.data();
      if (context.params.userId == date.matchUID) {
        const querySnapshot = await db.collection("userData")
            .doc(date.matchUID).collection("tokens").get();

        const tokens = querySnapshot.docs.map((snap) => snap.id);

        const payload: admin.messaging.MessagingPayload = {
          notification: {
            title: "You've got a date with ${date.name}",
            body: "Check it out in app",
            clickAction: "FLUTTER_NOTIFICATION_CLICK",
          },
        };
        fcm.sendToDevice(tokens, payload);
      }
    });
