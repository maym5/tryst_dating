import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'package:rendezvous_beta_v3/pages/discover_page.dart';
import 'package:rendezvous_beta_v3/pages/match_page.dart';
import 'package:rendezvous_beta_v3/pages/user_edit_page.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';

class HomePage extends StatefulWidget {
  static const id = "home_page";
  const HomePage({Key? key, this.initialPage = 1, this.firstTime = false}) : super(key: key);
  final int initialPage;
  final bool firstTime;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final PageController _controller;
  late int _currentPage;

  Widget get _floatingActionButton => FloatingActionButton(
        onPressed: () {
          _navigateTo(1);
        },
        child: const Icon(CupertinoIcons.heart),
        foregroundColor: Colors.white,
        backgroundColor: Colors.redAccent,
      );

  Widget get _bottomAppBar => BottomAppBar(
        color: kDarkTransparent,
        shape: const CircularNotchedRectangle(),
        notchMargin: 5.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
                onPressed: () {
                  _navigateTo(0);
                },
                icon: const Icon(Icons.person_outlined),
                color: _currentPage == 0 ? Colors.redAccent : Colors.white),
            IconButton(
                onPressed: () {
                  _navigateTo(2);
                },
                icon: const Icon(Icons.calendar_today),
                color: _currentPage == 2 ? Colors.redAccent : Colors.white)
          ],
        ),
      );

  void _navigateTo(int page) {
    if (_controller.hasClients) {
      _controller.animateToPage(page,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInSine);
      setState(() => _currentPage = page);
    }
  }

  @override
  void initState() {
    _controller = PageController(initialPage: widget.initialPage);
    _currentPage = widget.initialPage;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      extendBodyBehindAppBar: true,
      floatingActionButton: _floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomAppBar: _bottomAppBar,
      body: PageView(
        onPageChanged: (page) {
          setState(() => _currentPage = page);
        },
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          UserEditPage(
            onHomePageButtonPress: () {},
          ),
          DiscoverPage(firstTime: widget.firstTime),
          const MatchPage(),
        ],
      ),
    );
  }
}
