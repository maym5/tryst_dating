import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'package:rendezvous_beta_v3/pages/login_page.dart';
import 'package:rendezvous_beta_v3/pages/sign_up_page.dart';
import 'package:rendezvous_beta_v3/widgets/gradient_button.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';

class IntroPage extends StatelessWidget {
  static const id = "intro_page";
  const IntroPage({Key? key}) : super(key: key);

  Widget get _caitlin => Transform.rotate(angle: pi/10,
  child: const IntroPic(image: AssetImage("assets/images/caitlin_image2.jpg")));

  Widget get _rebecca => Transform.rotate(angle: -pi/10,
  child: const IntroPic(image: AssetImage("assets/images/rebecca.jpeg")));

  Widget get _image => SizedBox(height: 300, width: double.infinity, child: Image.asset("assets/images/love.png"),);

  Widget loginButton(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
    child: GradientButton(
        title: "Login",
        onPressed: () async {
          Navigator.pushNamed(context, LoginPage.id);
        }),
  );

  Widget signUpButton(BuildContext context) => GradientButton(
      title: "Sign Up",
      onPressed: () async {
        Navigator.pushNamed(context, SignUpPage.id);
      });

  Widget get _introParagraph => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
        "The dating app that puts dates ahead of swipes. "
            "By generating a date idea as soon as you match to help get the ball rolling,"
            " online dating has never been easier. So what are you waiting for? Start an account and remember"
            " every adventure starts with a Rendezvous.", style: kTextStyle.copyWith(fontSize: 18), textAlign: TextAlign.center,
    ),
  );

  Widget get _title => const Padding(
    padding: EdgeInsets.only(bottom: 10),
    child: Text(
      "Welcome to Rendezvous",
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.redAccent, fontSize: 35),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      decoration: kWelcomePageDecoration,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _image,
            _title,
            _introParagraph,
            loginButton(context),
            signUpButton(context),
          ],
        ),
      ),
    );
  }
}

class IntroPic extends StatelessWidget {
  const IntroPic({Key? key, required this.image}) : super(key: key);
  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: 170,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image(image: image, fit: BoxFit.cover),
      ),
    );
  }
}

