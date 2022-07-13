import 'package:flutter/material.dart';
import '../animations/bounce_animation.dart';
import '../constants.dart';

class GradientButton extends StatefulWidget {
  const GradientButton({Key? key, required this.title, required this.onPressed})
      : super(key: key);
  final String title;
  final void Function() onPressed;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
    );
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  Widget get _button => Container(
    height: 80,
    width: 250,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(50),
      gradient: kButtonGradient,
    ),
    child: Text(
      widget.title,
      style: kTextStyle.copyWith(color: Colors.white),
      textAlign: TextAlign.center,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      child: BounceAnimation(
        controller: _animationController,
        child: _button
      ),
    );
  }
}
