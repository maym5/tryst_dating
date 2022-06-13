import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/pages/login_page.dart';
import 'package:rendezvous_beta_v3/pages/sign_up_page.dart';
import 'package:rendezvous_beta_v3/widgets/gradient_button.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';

import '../models/users.dart';

class IntroPage extends StatelessWidget {
  static const id = "intro_page";
  const IntroPage({Key? key}) : super(key: key);

  Widget loginButton(BuildContext context) => GradientButton(
      title: "Login",
      onPressed: () async {
        await UserData().setLocation();
        Navigator.pushNamed(context, LoginPage.id);
      });

  Widget signUpButton(BuildContext context) => GradientButton(title: "Sign Up", onPressed: () async {
    await UserData().setLocation();
    Navigator.pushNamed(context, SignUpPage.id);
  });

  @override
  Widget build(BuildContext context) {
    return PageBackground(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              loginButton(context),
              signUpButton(context),
            ],
          ),
        ),
    );
  }
}
