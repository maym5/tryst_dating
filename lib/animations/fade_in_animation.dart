import 'package:flutter/material.dart';

class FadeInAnimation extends StatefulWidget {
  const FadeInAnimation(
      {Key? key,
      required this.child,
      this.duration,
      this.offsetCurve,
      this.fadeCurve,
      this.horizontalOffset,
      this.verticalOffset})
      : super(key: key);
  final Widget child;
  final Duration? duration;
  final Curve? offsetCurve;
  final Curve? fadeCurve;
  final double? horizontalOffset;
  final double? verticalOffset;

  @override
  _FadeInAnimationState createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;
  late CurvedAnimation _fadeCurve;
  late CurvedAnimation _offsetCurve;

  @override
  void initState() {
    _animController = AnimationController(
        vsync: this,
        duration: widget.duration ?? const Duration(milliseconds: 800));

    _offsetCurve = CurvedAnimation(
      curve: widget.offsetCurve ?? Curves.decelerate,
      parent: _animController,
    );

    _fadeCurve = CurvedAnimation(
        parent: _animController, curve: widget.fadeCurve ?? Curves.linear);

    _offsetAnimation = Tween<Offset>(
      begin:
          Offset(widget.horizontalOffset ?? 0.35, widget.verticalOffset ?? 0),
      end: Offset.zero,
    ).animate(_offsetCurve);

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_fadeCurve);

    _animController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _offsetAnimation,
        child: widget.child,
      ),
    );
  }
}
