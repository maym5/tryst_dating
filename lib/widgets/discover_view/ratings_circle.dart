import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../constants.dart';

class RatingsCircle extends StatelessWidget {
  const RatingsCircle(
      {Key? key, required this.visible, required this.userRating})
      : super(key: key);
  final bool visible;
  final double userRating;
  final double _radius = 120;
  final double _lineWidth = 15;

  Widget _filter({required Widget child}) =>  BackdropFilter(
      filter: ImageFilter.blur(
          sigmaX: visible ? 10 : 0,
          sigmaY: visible ? 10 : 0
      ),
    child: child,
  );

  Widget _opacityAnimation({required Widget child}) => AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: visible
          ? const Duration(milliseconds: 200)
          : const Duration(milliseconds: 1500),
    child: child,
  );

  Text get _displayedRating => Text(
    userRating.toStringAsFixed(1),
    style: kTextStyle.copyWith(fontSize: 50),
  );

  double get _percent => userRating / 10;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.5),
      child: _filter(
        child: _opacityAnimation(
          child: CircularPercentIndicator(
            linearGradient: kRatingCircleGradient,
            radius: _radius,
            lineWidth: _lineWidth,
            reverse: true,
            percent: _percent,
            circularStrokeCap: CircularStrokeCap.round,
            center: _displayedRating,
            backgroundColor: kDarkTransparent,
          ),
        ),
      ),
    );
  }
}
