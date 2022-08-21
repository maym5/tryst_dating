import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/models/users.dart';

import '../widgets/chat_view/chat_view.dart';

class PushNotificationService {
  PushNotificationService();

  static Future<void> initialize() async {
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;
    if (Platform.isIOS) {
      _fcm.requestPermission();
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
        // print("initial message: $message");
        if (message != null) {
          final _rawData = await FirebaseFirestore.instance
              .collection("userData")
              .doc(message.data["sender"])
              .get();
          MessageNavigator(
            name: _rawData["name"],
            sender: message.data["sender"],
            image: _rawData["images"][0],
          );
        }
      });

      // FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      //   print("onMessage: $message");
      //   final _rawData = await FirebaseFirestore.instance
      //       .collection("userData")
      //       .doc(message.data["sender"])
      //       .get();
      //   MessageNavigator(
      //     name: _rawData["name"],
      //     sender: message.data["sender"],
      //     image: _rawData["images"][0],
      //   );
      // });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
        print("onMessageOpenedApp: $message");
        final _rawData = await FirebaseFirestore.instance
            .collection("userData")
            .doc(message.data["sender"])
            .get();
        MessageNavigator(
          name: _rawData["name"],
          sender: message.data["sender"],
          image: _rawData["images"][0],
        );
      });


      FirebaseMessaging.onBackgroundMessage((message) async {
        print("onBackggroundMessage: $message");
        final _rawData = await FirebaseFirestore.instance
            .collection("userData")
            .doc(message.data["sender"])
            .get();
        MessageNavigator(
          name: _rawData["name"],
          sender: message.data["sender"],
          image: _rawData["images"][0],
        );
      });
    }
  }
}

class MessageNavigator extends StatefulWidget {
  const MessageNavigator(
      {Key? key, required this.image, required this.name, required this.sender})
      : super(key: key);
  final String image;
  final String name;
  final String sender;

  @override
  State<MessageNavigator> createState() => _MessageNavigatorState();
}

class _MessageNavigatorState extends State<MessageNavigator> {
  @override
  Widget build(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatView(
                  image: widget.image,
                  name: widget.name,
                  match: widget.sender,
                )));
    return Container();
  }
}
