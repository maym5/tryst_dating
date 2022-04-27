import 'dart:math';

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class LikeWidget extends StatelessWidget {
  LikeWidget({Key? key, required this.animation, required this.userRating}) : super(key: key);
  final ValueNotifier<double> animation;
  final double userRating;
  double animationSpeed = 1;

  Widget getCPI({required Widget center}) => CircularPercentIndicator(
        circularStrokeCap: CircularStrokeCap.butt,
        percent: min(
        animationSpeed * animation.value <= 1 &&
        animation.value >= 0
        ? animationSpeed * animation.value
            : 1,
        userRating / 10),
    progressColor:
    userRating >= 5 ? Colors.green : Colors.redAccent,
    lineWidth: 20.0,
    reverse: true,
    radius: 150,
    backgroundColor: Colors.transparent,
      center: center,
    );

  Widget getVisibility({required Widget child}) => Visibility(
      visible:
      animation.value == animation.value.round() || animation.value <= 0
          ? false
          : true,
      child: child
  );

  Widget getOpacity({required Widget child}) => Opacity(
      opacity: 3 * animation.value >= 0 && 3 * animation.value <= 1
          ? 3 * animation.value
          : animation.value >= 0 ? 1 - animation.value : 0,
    child: child,
  );

  Widget get centerTitle => const Padding(
    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
    child: Text(
      'Your Rating:',
      style: TextStyle(
        color: Colors.white,
        fontFamily: 'Raleway',
        fontWeight: FontWeight.w400,
        fontSize: 30,
      ),
    ),
  );

  Widget get centerText => Text(
    userRating.toStringAsFixed(1),
    style: const TextStyle(
      color: Colors.white,
      fontFamily: 'Raleway', // get techno font here
      fontWeight: FontWeight.bold,
      fontSize: 50,
    ),
  );

  Widget get centerIcon => userRating >= 5
      ? const Icon(
    Icons.favorite,
    color: Colors.redAccent,
    size: 50.0,
  )
      : const Icon(
    Icons.clear,
    color: Colors.orange,
    size: 50.0,
  );

  Widget get centerUI => FittedBox(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        centerTitle,
        centerText,
        centerIcon
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    animationSpeed = userRating / 2.5;
    return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, _) => getVisibility(
            child: getOpacity(
                child: getCPI(
                    center: centerUI,
                )
            )
        ),
    );
  }
}
