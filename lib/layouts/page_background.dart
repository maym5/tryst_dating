import 'package:flutter/material.dart';

class PageBackground extends StatelessWidget {
  const PageBackground({Key? key, this.appBar, this.bottomAppBar, required this.body}) : super(key: key);
  final PreferredSizeWidget? appBar;
  final Widget? bottomAppBar;
  final Widget body;


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
            appBar: appBar,
            bottomNavigationBar: bottomAppBar,
            body: body
          ),
        ),
      ),
    );
  }
}
