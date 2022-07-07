import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'package:rendezvous_beta_v3/pages/user_edit_page.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';
import '../services/authentication_service.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({Key? key}) : super(key: key);
  static const id = "verification_page";

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  bool _isEmailVerified = false;
  Timer? _timer;

  Widget get _title => const Text(
    "We sent you a verification email",
    textAlign: TextAlign.center,
    style: TextStyle(
      color: Colors.redAccent,
      fontSize: 35
    ),
  );

  Widget get _description => Text(
    "It helps us keep Rendezvous a safe place to date (and you gotta do it), so click the link and get verified!",
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

  Widget get _titleAndDescription => Column(
    children: [
      _title,
      const SizedBox(height: 20),
      _description,
    ],
  );

  void _setEmailVerified() async {
      _isEmailVerified = await AuthenticationService.checkEmailVerified();
  }

  @override
  void initState() {
    _setEmailVerified();
    if (_isEmailVerified) {
      Navigator.pushNamed(context, UserEditPage.id);
    } else {
      AuthenticationService.sendVerificationEmail();
      _timer = Timer.periodic(const Duration(seconds: 3), (_) {
        _setEmailVerified();
        if (_isEmailVerified) {
          _timer?.cancel();
          Navigator.pushNamed(context, UserEditPage.id);
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _artToComLater,
            _titleAndDescription,
          ],
        )
    );
  }
}

