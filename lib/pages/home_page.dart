import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/pages/discover_page.dart';
import 'package:rendezvous_beta_v3/pages/user_edit_page.dart';

class HomePage extends StatelessWidget {
  static const id = "home_page";
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: const <Widget>[
        UserEditPage(),
        DiscoverPage()
      ],
    );
  }
}
