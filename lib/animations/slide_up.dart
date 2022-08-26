import 'package:flutter/material.dart';

class SlideUp extends StatefulWidget {
  const SlideUp({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  State<SlideUp> createState() => _SlideUpState();
}

class _SlideUpState extends State<SlideUp> with TickerProviderStateMixin {
  late final AnimationController _controller;

  late final Tween<Offset> _offset = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.9));

  late final Animation<Offset> _animation = _offset.animate(_controller);

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
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
    return SlideTransition(
        position: _animation,
      child: widget.child,
    );
  }
}
