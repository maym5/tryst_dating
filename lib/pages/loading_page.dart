import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/animations/text_fade_in.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'package:rendezvous_beta_v3/pages/home_page.dart';
import 'package:rendezvous_beta_v3/pages/intro_page.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';

import '../models/users.dart';

class LoadingPage extends StatefulWidget {
  static const id = "loading_page";
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future fakeDelay() async {
    await Future.delayed(const Duration(seconds: 4));
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await UserData().setLocation();
      await UserData().getUserData();
      Navigator.pushNamed(context, HomePage.id);
    } else {
      Navigator.pushNamed(context, IntroPage.id);
    }
  }

  @override
  void initState() {
    fakeDelay();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      body: Center(
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => kButtonGradient
              .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: TextFadeIn(text: "Rendezvous", style: kTextStyle.copyWith(fontSize: 50)),
        ),
      ),
    );
  }
}