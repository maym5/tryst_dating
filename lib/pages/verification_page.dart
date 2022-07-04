import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/widgets/gradient_button.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';
import '../services/authentication.dart';

class VerificationPage extends StatelessWidget {
  const VerificationPage({Key? key}) : super(key: key);
  static const id = "verification_page";

  Widget get _title => const Text(
    "Verify your email!",
    style: TextStyle(
      color: Colors.redAccent,
      fontSize: 35
    ),
  );

  Widget get _description => Text(
    "It helps us keep Rendezvous a safe place to date (and you gotta do it), so click that button and join the Rendezvous community",
    style: TextStyle(
      color: Colors.redAccent.withOpacity(0.7),
      fontSize: 25
    ),
  );

  Widget get _button => GradientButton(
      title: "Verify Email",
      onPressed: _onPressed
  );

  void _onPressed() async {
    try {
      await AuthenticationService().verifyEmail();
    } catch(e) {
      if (e == "invalid user") {
        // what to do here?
        print("user was invalid");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
        body: Column(
          children: [
            _title,
            _description,
            const SizedBox(height: 25),
            _button
          ],
        )
    );
  }
}
