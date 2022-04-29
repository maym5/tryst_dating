import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/pages/discover_page.dart';
import 'package:rendezvous_beta_v3/pages/temp_sign_out.dart';

class HomePage extends StatelessWidget {
  static const id = "home_page";
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: <Widget>[
        TempLogOut(),
        const DiscoverPage()
      ],
    );
  }
}
