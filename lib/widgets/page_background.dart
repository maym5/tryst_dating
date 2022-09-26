import 'package:flutter/material.dart';

import '../constants.dart';

class PageBackground extends StatelessWidget {
  const PageBackground(
      {Key? key,
      this.appBar,
      this.bottomAppBar,
      required this.body,
      this.floatingActionButton,
      this.floatingActionButtonLocation,
      this.extendBodyBehindAppBar = false,
      this.intro = false,
      this.decoration})
      : super(key: key);
  final PreferredSizeWidget? appBar;
  final Widget? bottomAppBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBodyBehindAppBar;
  final bool intro;
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: decoration ?? kIntroPageBackgroundDecoration,
          child: Scaffold(
              backgroundColor: Colors.transparent,
              extendBody: extendBodyBehindAppBar,
              resizeToAvoidBottomInset: false,
              appBar: appBar,
              bottomNavigationBar: bottomAppBar,
              floatingActionButton: floatingActionButton,
              floatingActionButtonLocation: floatingActionButtonLocation,
              body: body),
        ),
      ),
    );
  }
}
