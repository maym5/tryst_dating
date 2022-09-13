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


class RatingDisplay extends StatelessWidget {
  const RatingDisplay({Key? key, required this.userRating, required this.visible}) : super(key: key);
  final bool visible;
  final double userRating;

  Text get _displayedRating => Text(
    userRating.toStringAsFixed(1),
    style: kTextStyle.copyWith(fontSize: 90),
  );

  Widget _opacityAnimation({required Widget child}) => AnimatedOpacity(
    opacity: visible ? 1.0 : 0.0,
    duration: visible
        ? const Duration(milliseconds: 200)
        : const Duration(milliseconds: 1500),
    child: child,
  );

  Widget _filter({required Widget child}) =>  BackdropFilter(
    filter: ImageFilter.blur(
        sigmaX: visible ? 10 : 0,
        sigmaY: visible ? 10 : 0
    ),
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.3),
      child: _filter(child: _opacityAnimation(child: _displayedRating)),
    );
  }
}



class VerticalRatingSlider extends StatefulWidget {
  const VerticalRatingSlider({Key? key, required this.onChanged, required this.onChangeEnd, required this.onChangeStart}) : super(key: key);
  final void Function(double) onChanged;
  final void Function(double) onChangeStart;
  final void Function(double) onChangeEnd;

  @override
  State<VerticalRatingSlider> createState() => _VerticalRatingSliderState();
}

class _VerticalRatingSliderState extends State<VerticalRatingSlider> {
  late double _userRating;

  @override
  void initState() {
    _userRating = 5;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0.9, 0.9),
      child: Container(
        alignment: Alignment.center,
        height: 400,
        width: 100,
        child: RotatedBox(
          quarterTurns: 3,
          child: Slider(
            value: _userRating,
            min: 0,
            max: 10,
            onChanged: (rating) {
              setState(() => _userRating = rating);
              widget.onChanged(rating);
            },
            onChangeEnd: widget.onChangeEnd,
            onChangeStart: widget.onChangeStart,
            inactiveColor: Colors.white10,
            activeColor: Colors.black54,
            thumbColor: Colors.white24,
          ),
        ),
      ),
    );
  }
}

class HorizontalRatingSlider extends StatefulWidget {
  const HorizontalRatingSlider({Key? key, required this.onChanged, required this.onChangeStart, required this.onChangeEnd,required this.visible }) : super(key: key);
  final void Function(double) onChanged;
  final void Function(double) onChangeStart;
  final void Function(double) onChangeEnd;
  final bool visible;

  @override
  State<HorizontalRatingSlider> createState() => _HorizontalRatingSliderState();
}

class _HorizontalRatingSliderState extends State<HorizontalRatingSlider> {
  late double _userRating;

  @override
  void initState() {
    _userRating = 5;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.visible,
      child: Align(
        alignment: const Alignment(0, 0.45),
        child: Container(
          alignment: Alignment.center,
          height: 100,
          width: double.infinity,
          child: Slider(
            value: _userRating,
            min: 0,
            max: 10,
            onChanged: (rating) {
              setState(() => _userRating = rating);
              widget.onChanged(rating);
            },
            onChangeEnd: widget.onChangeEnd,
            onChangeStart: widget.onChangeStart,
            inactiveColor: Colors.white10,
            activeColor: Colors.black54,
            thumbColor: Colors.white24,
          ),
        ),
      ),
    );
  }
}


class RatingStack extends StatefulWidget {
  const RatingStack({Key? key, required this.onChanged, required this.visible}) : super(key: key);
  final void Function(double) onChanged;
  final bool visible;

  @override
  State<RatingStack> createState() => _RatingStackState();
}

class _RatingStackState extends State<RatingStack> {
  late bool _visible;
  late double _userRating;

  @override
  void initState() {
    _visible = false;
    _userRating= 5.0;
    super.initState();
  }

  void _onChanged(double rating) {
    setState(() {
      _userRating = rating;
    });
  }

  void _onChangeStart(double rating) {
    setState(() {
      _visible = true;
    });
    widget.onChanged(rating);
  }

  void _onChangeEnd(double rating) {
    setState(() {
      _visible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RatingDisplay(
            userRating: _userRating,
            visible: _visible
        ),
        HorizontalRatingSlider(
          visible: widget.visible,
            onChanged: _onChanged,
            onChangeStart: _onChangeStart,
          onChangeEnd: _onChangeEnd,
        )
      ],
    );
  }
}


