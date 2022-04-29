import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'package:rendezvous_beta_v3/pages/discover_page.dart';
import 'package:rendezvous_beta_v3/pages/home_page.dart';
import 'package:rendezvous_beta_v3/pages/sign_up_page.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';

class IntroPage extends StatefulWidget {
  static const id = "intro_page";
  const IntroPage({Key? key}) : super(key: key);

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  // TODO: initialize with UserData to avoid error grab location
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future fakeDelay() async {
    // UserData.location = await _getPosition();
    await Future.delayed(const Duration(seconds: 4));
    setState(() {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        Navigator.pushNamed(context, HomePage.id);
      } else {
        Navigator.pushNamed(context, SignUpPage.id);
      }
    });
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
          child: Text("Rendezvous", style: kTextStyle.copyWith(fontSize: 50)),
        ),
      ),
    );
  }
}
