import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/pages/login_page.dart';
import 'package:rendezvous_beta_v3/pages/sign_up_page.dart';
import 'package:rendezvous_beta_v3/widgets/gradient_button.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';

class IntroPage extends StatelessWidget {
  static const id = "intro_page";
  const IntroPage({Key? key}) : super(key: key);

  Widget loginButton(BuildContext context) => GradientButton(
      title: "Login",
      onPressed: () {
        Navigator.pushNamed(context, LoginPage.id);
      });

  Widget signUpButton(BuildContext context) => GradientButton(title: "Sign Up", onPressed: () {
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
