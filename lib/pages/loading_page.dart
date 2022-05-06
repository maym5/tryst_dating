import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/animations/text_fade_in.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'package:rendezvous_beta_v3/pages/home_page.dart';
import 'package:rendezvous_beta_v3/pages/sign_up_page.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';

import '../models/users.dart';

class LoadingPage extends StatefulWidget {
  static const id = "intro_page";
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future fakeDelay() async {
    UserData.location = await UserData.userLocation;
    // GooglePlacesService(venueType: "cafe").venues;
    await Future.delayed(const Duration(seconds: 4));
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      final DocumentSnapshot<Map<String, dynamic>> _rawData =
          await _firestore.collection("userData").doc(currentUser.uid).get();
      final Map<String, dynamic> _data = _rawData.data()!;
      UserData.fromJson(_data);
      Navigator.pushNamed(context, HomePage.id);
    } else {
      Navigator.pushNamed(context, SignUpPage.id);
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