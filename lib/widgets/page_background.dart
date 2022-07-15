import 'package:flutter/material.dart';

class PageBackground extends StatelessWidget {
  const PageBackground({Key? key, this.appBar, this.bottomAppBar, required this.body, this.floatingActionButton, this.floatingActionButtonLocation, this.extendBodyBehindAppBar = false}) : super(key: key);
  final PreferredSizeWidget? appBar;
  final Widget? bottomAppBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBodyBehindAppBar;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                Colors.blueGrey[300]!,
                Colors.blueGrey[400]!,
                Colors.blueGrey[500]!,
                Colors.blueGrey[600]!,
              ],
            stops: const [
              0.1, 0.5, 0.7, 0.9
            ],
          ),
        ),
        child: WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Scaffold(
            extendBody: extendBodyBehindAppBar,
            appBar: appBar,
            bottomNavigationBar: bottomAppBar,
            floatingActionButton: floatingActionButton,
            floatingActionButtonLocation: floatingActionButtonLocation,
            body: body
          ),
        ),
      ),
    );
  }
}
