import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/models/users.dart';

import '../pages/home_page.dart';
import '../widgets/chat_view/chat_view.dart';

class PushNotificationService {
  PushNotificationService();

  static Future<void> initialize() async {
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;
    final NotificationSettings _initialStatus =
        await _fcm.getNotificationSettings();
    if (Platform.isIOS &&
        _initialStatus.authorizationStatus != AuthorizationStatus.authorized) {
      await _fcm.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true);
    }
    final NotificationSettings _status = await _fcm.getNotificationSettings();
    if (_status.authorizationStatus != AuthorizationStatus.denied) {
      // do some shit

      _fcm.setAutoInitEnabled(true);

      UserData.tokenData = {
        "token": await _fcm.getToken(),
        "device": Platform.operatingSystem,
        "createdAt": FieldValue.serverTimestamp()
      };

      UserData.uploadTokenData();

      _fcm.getInitialMessage().then((RemoteMessage? message) async {
        if (message != null && message.data["sender"] != null) {
          final _rawData = await FirebaseFirestore.instance
              .collection("userData")
              .doc(message.data["sender"])
              .get();
          MessageNavigator(
            name: _rawData["name"],
            sender: message.data["sender"],
            image: _rawData["images"][0],
          );
        } else {
          const MessageNavigator();
        }
      });

      FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage message) async {
        // TODO: we have two notifications now might not work
        if (message.data["sender"] != null) {
          final _rawData = await FirebaseFirestore.instance
              .collection("userData")
              .doc(message.data["sender"])
              .get();
          MessageNavigator(
            name: _rawData["name"],
            sender: message.data["sender"],
            image: _rawData["images"][0],
          );
        } else {
          const MessageNavigator();
        }
      });

      FirebaseMessaging.onBackgroundMessage((message) async {
        if (message.data["sender"] != null) {
          final _rawData = await FirebaseFirestore.instance
              .collection("userData")
              .doc(message.data["sender"])
              .get();
          MessageNavigator(
            name: _rawData["name"],
            sender: message.data["sender"],
            image: _rawData["images"][0],
          );
        } else {
          const MessageNavigator();
        }
      });
    }
  }
}

class MessageNavigator extends StatefulWidget {
  const MessageNavigator({Key? key, this.image, this.name, this.sender})
      : super(key: key);
  final String? image;
  final String? name;
  final String? sender;

  @override
  State<MessageNavigator> createState() => _MessageNavigatorState();
}

class _MessageNavigatorState extends State<MessageNavigator> {
  @override
  Widget build(BuildContext context) {
    if (widget.sender != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatView(
                    image: widget.image!,
                    name: widget.name!,
                    match: widget.sender!,
                  )));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const HomePage(initialPage: 2)));
    }
    return Container();
  }
}
