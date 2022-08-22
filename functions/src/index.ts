import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();
const fcm = admin.messaging();

export const sendToTokens = functions.firestore
    .document("userData/{userId}/matches/{matchId}/messages/{messageId}")
    .onCreate(async (snapshot, context) => {
      const message = snapshot.data();
      if (context.params.userId != message.target) {
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
