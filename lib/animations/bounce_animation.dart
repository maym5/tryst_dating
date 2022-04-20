import 'package:flutter/material.dart';


class BounceAnimation extends StatefulWidget {
  const BounceAnimation({Key? key, required this.child, required this.controller}) : super(key: key);
  final Widget child;
  final AnimationController controller;

  @override
  _BounceAnimationState createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<BounceAnimation> {
  late Animation<double> _scale;
  late CurvedAnimation _curve;

  @override
  void initState() {
    _curve = CurvedAnimation(
      curve: Curves.decelerate,
      parent: widget.controller,
    );
    _scale = Tween<double>(begin: 1, end: 0.9).animate(_curve);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
        scale: _scale,
        child: widget.child
    );
  }
}
