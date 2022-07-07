import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'package:rendezvous_beta_v3/pages/user_edit_page.dart';
import 'package:rendezvous_beta_v3/widgets/gradient_button.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';
import '../services/authentication_service.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({Key? key}) : super(key: key);
  static const id = "verification_page";

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  late bool _showSpinner;

  Widget get _title => const Text(
    "Verify your email!",
    style: TextStyle(
      color: Colors.redAccent,
      fontSize: 35
    ),
  );

  Widget get _description => Text(
    "It helps us keep Rendezvous a safe place to date (and you gotta do it), so click that button and join the Rendezvous community",
    textAlign: TextAlign.center,
    style: TextStyle(
      color: kTextStyle.color,
      fontSize: 25
    ),
  );

  Widget get _artToComLater => Container(
    width: 150,
    height: 150,
    color: Colors.redAccent,
  );

  Widget get _button => GradientButton(
      title: "Verify Email",
      onPressed: _onPressed
  );

  Widget get _titleAndDescription => Column(
    children: [
      _title,
      const SizedBox(height: 20),
      _description,
    ],
  );

  void _onPressed() async {
    try {
      setState(() => _showSpinner = true);
      await AuthenticationService().verifyEmail();
      setState(() => _showSpinner = false);
      User? _user = AuthenticationService.currentUser;
      if (_user != null && _user.emailVerified) {
        Navigator.pushNamed(context, UserEditPage.id);
      } else if (_user == null) {
        // there is no user
      } else {
        // user already verified
      }
    } catch(e) {
      if (e == "invalid user") {
        // what to do here?
        print("user was invalid");
      }
    }
  }

  @override
  void initState() {
    _showSpinner = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
        body: ModalProgressHUD(
          inAsyncCall: _showSpinner,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _artToComLater,
              _titleAndDescription,
              _button
            ],
          ),
        )
    );
  }
}
