import 'package:flutter/material.dart';
import '../animations/bounce_animation.dart';
import '../constants.dart';

class RoundButton extends StatefulWidget {
  const RoundButton({Key? key, required this.icon, required this.title, required this.onPressed, this.gradient}) : super(key: key);
  final IconData icon;
  final String title;
  final void Function() onPressed;
  final LinearGradient? gradient;

  @override
  State<RoundButton> createState() => _RoundButtonState();
}

class _RoundButtonState extends State<RoundButton> with TickerProviderStateMixin{
  late final AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    super.initState();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      child: BounceAnimation(
        controller: _controller,
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: widget.gradient,
              color: kInactiveColor
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(widget.icon, size: 30, color: Colors.white,),
                FittedBox(child: Text(widget.title, style: kTextStyle.copyWith(fontSize: 20),)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}