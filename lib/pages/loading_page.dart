import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/animations/fade_in_animation.dart';
import 'package:rendezvous_beta_v3/animations/text_fade_in.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'package:rendezvous_beta_v3/pages/home_page.dart';
import 'package:rendezvous_beta_v3/pages/intro_page.dart';
import 'package:rendezvous_beta_v3/pages/user_edit_page.dart';
import 'package:rendezvous_beta_v3/pages/verification_page.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';

import '../models/users.dart';

class LoadingPage extends StatefulWidget {
  static const id = "loading_page";
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  late bool _showIndicator;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future load() async {
    await Future.delayed(const Duration(seconds: 4));
    FirebaseFirestore _db = FirebaseFirestore.instance;
    final User? currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.emailVerified) {
      setState(() => _showIndicator = true);
      _db.collection("userData").doc(currentUser.uid)
          .get()
          .then(
              (doc) async {
                if (doc.exists) {
                  await UserData().getUserData();
                  setState(() => _showIndicator = false);
                  Navigator.pushNamed(context, HomePage.id);
                } else {
                  Navigator.pushNamed(context, UserEditPage.id);
                }
              });
    } else if (currentUser == null) {
      Navigator.pushNamed(context, IntroPage.id);
    } else if (!currentUser.emailVerified) {
      Navigator.pushNamed(context, VerificationPage.id);
    } else {
      Navigator.pushNamed(context, IntroPage.id);
    }
  }

  Widget get _progressIndicator => _showIndicator
      ? const Padding(
          padding: EdgeInsets.only(top: 15),
          child: SizedBox(
              child: CircularProgressIndicator(color: Colors.redAccent),
              height: 40,
              width: 40),
        )
      : Container();

  Widget get _logo => Image.asset(
    "assets/images/rendezvous_logo.png",
    height: 300,
    width: 300,
  );

  @override
  void initState() {
    _showIndicator = false;
    load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      intro: true,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeInAnimation(
              delay: 1500,
              verticalOffset: -0.35,
              horizontalOffset: 0,
              child: _logo,
            ),
            const SizedBox(
              height: 25,
            ),
            TextFadeIn(
                text: "tryst",
                style:
                    kTextStyle.copyWith(fontSize: 50, color: Colors.redAccent)),
            _progressIndicator
          ],
        ),
      ),
    );
  }
}
