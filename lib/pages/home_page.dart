import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/pages/discover_page.dart';
import 'package:rendezvous_beta_v3/pages/match_page.dart';
import 'package:rendezvous_beta_v3/pages/user_edit_page.dart';

class HomePage extends StatelessWidget {
  static const id = "home_page";
  const HomePage({Key? key}) : super(key: key);

  PageController get _controller => PageController(initialPage: 1);

  void _userEditButtonPress() {
    _controller.animateToPage(1, duration: const Duration(milliseconds: 200), curve: Curves.easeInSine);
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      children: <Widget>[
        UserEditPage(onHomePageButtonPress: _userEditButtonPress),
        const DiscoverPage(),
        const MatchPage(),
      ],
    );
  }
}
