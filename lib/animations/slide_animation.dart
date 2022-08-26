

import 'package:flutter/material.dart';

class SlideAnimation extends StatefulWidget {
  const SlideAnimation({Key? key, required this.child, required this.complete}) : super(key: key);
  final Widget child;
  final void Function() complete;

  @override
  State<SlideAnimation> createState() => _SlideAnimationState();
}

class _SlideAnimationState extends State<SlideAnimation> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late double _alignment;

  late final Animation<double> tweenSequence = TweenSequence<double>(
      [
        TweenSequenceItem<double>(tween: Tween<double>(begin: 0, end: 0.9), weight: 40),
        TweenSequenceItem<double>(tween: Tween<double>(begin: 0.9, end: 0), weight: 10),
        TweenSequenceItem<double>(tween: Tween<double>(begin: 0, end: -0.9), weight: 40),
        TweenSequenceItem<double>(tween: Tween<double>(begin: -0.9, end: 0), weight: 10),
      ]
  ).animate(_controller);

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 7));
    _alignment = 0.0;
    _controller.addListener(() {
      setState(() {
        _alignment = tweenSequence.value;
      });
      if (_controller.isCompleted) {
        widget.complete();
      }
    });
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(_alignment, 0),
      child: widget.child,
    );
  }
}



