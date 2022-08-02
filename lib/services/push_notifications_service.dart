import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rendezvous_beta_v3/models/users.dart';

class PushNotificationService {
  PushNotificationService();



  static Future initialize() async {
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;
    if (Platform.isIOS) {
      _fcm.requestPermission();
    }
    final NotificationSettings _status = await _fcm.getNotificationSettings();
    if (_status.authorizationStatus != AuthorizationStatus.denied) {
      // do some shit

      UserData.tokenData = {
        "token" : await _fcm.getToken(),
        "device" : Platform.operatingSystem,
        "createdAt" : FieldValue.serverTimestamp()
      };


      _fcm.getInitialMessage().then((RemoteMessage? message) {
        // TODO: implement
        print("initial message: $message");
      });


      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("onMessage: $message");
        RemoteNotification? notification = message.notification;
        if (Platform.isIOS && notification != null) {
          AppleNotification appleNotification = notification.apple!;
        } else if (Platform.isAndroid && notification != null) {
          AndroidNotification androidNotification = notification.android!;
        }
      });


      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("onMessageOpenedApp: $message");
        // TODO: implement
      });
    }
  }
}