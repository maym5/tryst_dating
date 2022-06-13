import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:rendezvous_beta_v3/services/authentication.dart';
import '../constants.dart';
import '../models/users.dart';
import '../widgets/fields/text_input_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/page_background.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  static const id = "login_page";
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // static late final TextEditingController _emailController = TextEditingController();
  // static late final TextEditingController _passwordController = TextEditingController();
  Map<String, String?> loginInputs = {
    "email" : null,
    "password" : null
  };
  Map<String, String> errorMessages = {
    "email" : "Please enter a valid email",
    "password" : "Please enter a valid email"
  };
  late bool showErrors;
  late bool _showSpinner;

  TextInputField get _emailField => TextInputField(
        title: "Email",
        onChanged: (email) {
          setState(() {
            if (email == "") {
              loginInputs['email'] = null;
            } else {
              loginInputs["email"] = email;
            }
          });
        },
        showError: loginInputs['email'] == null && showErrors,
    errorMessage: errorMessages['email'],
      );

  TextInputField get _passwordField => TextInputField(
    title: "Password",
    onChanged: (password) {
      setState(() {
        if (password == "") {
          loginInputs['password'] = null;
        } else {
          loginInputs["password"] = password;
        }
      });
    },
    showError: loginInputs['password'] == null && showErrors,
    errorMessage: errorMessages["password"],
  );


  void _handleSignIn() async {
    setState(() => _showSpinner = true);
    if (loginInputs['password'] != null && loginInputs['email'] != null) {
      var result = await onEmailAndPasswordLogin(loginInputs['email']!, loginInputs['password']!);
      setState(() => _showSpinner = false);
      if (result is String) {
        switch (result) {
          case 'invalid-email':
            setState(() {
              errorMessages["email"] = "Enter a valid email";
              showErrors = true;
            });
            break;
          case 'user-not-found':
            setState(() {
              errorMessages["email"] = "Cannot find user with that email";
              showErrors = true;
            });
            break;
          case 'wrong-password':
            setState(() {
              errorMessages["password"] = "Please enter a valid email";
              showErrors = true;
            });
            break;
          case 'too-many-requests':
            setState(() {
              errorMessages["email"] = "Too many requests, try again later";
              showErrors = true;
            });
            break;
        }
      } else {
        await UserData().getUserData();
        Navigator.pushNamed(context, HomePage.id);
      }
    }
  }

  @override
  void initState() {
    showErrors = false;
    _showSpinner = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: put in back arrow
    return PageBackground(
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        color: kDarkTransparent,
        progressIndicator: const CircularProgressIndicator(color: Colors.redAccent),
        child: Column(
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
                _emailField,
                _passwordField
              ],
            ),
            GradientButton(
                title: "Login",
                onPressed: _handleSignIn,
            ),
          ],
        ),
      ),
    );
  }
}
