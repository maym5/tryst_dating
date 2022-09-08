import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:rendezvous_beta_v3/pages/verification_page.dart';
import 'package:rendezvous_beta_v3/services/authentication_service.dart';
import 'package:rendezvous_beta_v3/services/push_notifications_service.dart';
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
  Map<String, String?> loginInputs = {"email": "", "password": ""};

  Map<String, String> errorMessages = {
    "email": "Please enter a valid email",
    "password": "Please enter a valid password"
  };

  late bool showEmailError;
  late bool showPasswordError;
  late bool _showSpinner;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  TextInputField get _emailField => TextInputField(
        title: "Email",
        controller: emailController,
        onChanged: (email) {
          setState(() {
            if (email == "") {
              loginInputs['email'] = null;
            } else {
              loginInputs["email"] = email;
            }
          });
        },
        showError: loginInputs['email'] == null || showEmailError,
        errorMessage: errorMessages['email'],
      );

  TextInputField get _passwordField => TextInputField(
        title: "Password",
        controller: passwordController,
        obscureText: true,
        onChanged: (password) {
          setState(() {
            if (password == "") {
              loginInputs['password'] = null;
            } else {
              loginInputs["password"] = password;
            }
          });
        },
        showError: loginInputs['password'] == null || showPasswordError,
        errorMessage: errorMessages["password"],
      );

  AppBar get _appBar => AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(
          onPressed: _navigateBack,
          color: Colors.redAccent,
        ),
      );

  void _handleSignIn() async {
    setState(() => _showSpinner = true);
    if (loginInputs['password'] != "" && loginInputs['email'] != "") {
      emailController.text = loginInputs["email"]!;
      passwordController.text = loginInputs["password"]!;
      var result = await AuthenticationService().onEmailAndPasswordLogin(
          loginInputs['email']!, loginInputs['password']!);
      setState(() => _showSpinner = false);
      if (result is String) {
        switch (result) {
          case 'invalid-email':
            setState(() {
              errorMessages["email"] = "Enter a valid email";
              showEmailError = true;
            });
            break;
          case 'user-not-found':
            setState(() {
              errorMessages["email"] = "Cannot find user with that email";
              showEmailError = true;
            });
            break;
          case 'wrong-password':
            setState(() {
              errorMessages["password"] = "Please enter a valid email";
              showEmailError = true;
            });
            break;
          case 'too-many-requests':
            setState(() {
              errorMessages["password"] = "Too many requests, try again later";
              showPasswordError = true;
            });
            break;
        }
      } else {
        if (result is User && result.emailVerified) {
          await UserData().setLocation();
          await UserData().getUserData();
          await PushNotificationService.initialize();
          Navigator.pushNamed(context, HomePage.id);
        } else {
          Navigator.pushNamed(context, VerificationPage.id);
        }
      }
    } else if (loginInputs['password'] == "") {
      setState(() => _showSpinner = false);
      loginInputs['password'] = null;
    } else {
      setState(() => _showSpinner = false);
      loginInputs['email'] = null;
    }
  }

  @override
  void initState() {
    showEmailError = false;
    _showSpinner = false;
    showPasswordError = false;
    super.initState();
  }

  void _navigateBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      decoration: kWelcomePageDecoration,
      appBar: _appBar,
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        color: kDarkTransparent,
        progressIndicator:
            const CircularProgressIndicator(color: Colors.redAccent),
        child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.asset("assets/images/login.png",
                  height: 250, width: double.infinity),
              const Text(
                "Log in and get back to dating, not swiping",
                style: TextStyle(color: Colors.redAccent, fontSize: 35),
                softWrap: true,
                textAlign: TextAlign.center,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[_emailField, _passwordField],
              ),
              const SizedBox(height: 15,),
              GradientButton(
                title: "Login",
                onPressed: _handleSignIn,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
