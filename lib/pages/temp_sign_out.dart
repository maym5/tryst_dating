import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/pages/sign_up_page.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';

class TempLogOut extends StatelessWidget {
  TempLogOut({Key? key}) : super(key: key);
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return PageBackground(
        body: Center(
          child: ElevatedButton(
            child: const Text("log out"),
            onPressed: () {
              auth.signOut().then((value) => Navigator.pushNamed(context, SignUpPage.id));
            },
          ),
        )
    );
  }
}
