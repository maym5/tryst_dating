import 'package:flutter/material.dart';

import '../fields/text_input_field.dart';
import '../layouts/gradient_button.dart';
import '../layouts/page_background.dart';

class SignUpPage extends StatefulWidget {
  static const id = "sign_up_page";
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String? _confirmMessage;
  Map<String, String?> userInputs = {
    "email" : null,
    "password" : null,
    "confirm" : null
  };
  late bool showErrors;

  bool get passwordsDontMatch => userInputs['password'] != userInputs["confirm"];

  TextInputField get emailField => TextInputField(
    title: "Email",
    onChanged: (email) {
      if (email == "") {
        userInputs['email'] = null;
      } else {
        userInputs["email"] = email;
      }
    },
    showError: userInputs['email'] == null && showErrors,
  );

  TextInputField get passwordField => TextInputField(
    title: "Password",
    onChanged: (password) {
      if (password == "") {
        userInputs['password'] = null;
      } else {
        userInputs["password"] = password;
      }
    },
    showError: userInputs['password'] == null && showErrors,
  );

  TextInputField get confirmField => TextInputField(
    title: "Confirm Password",
    onChanged: (confirm) {
      if (confirm == "") {
        userInputs['confirm'] = null;
      } else {
        userInputs["confirm"] = confirm;
      }
    },
    showError: (userInputs['confirm'] == null || passwordsDontMatch) && showErrors,
    errorMessage: _confirmMessage,
  );

  void _onPressed() {
    if (passwordsDontMatch) {
      setState(() {
        _confirmMessage = "Passwords don't match";
        showErrors = true;
      });
    } else {
      for (String? input in userInputs.values) {
        if (input == null) {
          setState(() {
            showErrors = true;
            return;
          });
        }
      }
      // add user and navigate
    }
  }

  @override
  void initState() {
    showErrors = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              height: 100,
              width: 100,
              color: Colors.redAccent,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                emailField,
                passwordField,
                confirmField
              ],
            ),
            GradientButton(title: "Sign Up", onPressed: _onPressed)
          ],
        ),
    );
  }
}
