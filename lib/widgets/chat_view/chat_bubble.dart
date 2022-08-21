import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'dart:math';

class InBubble extends StatelessWidget {
  const InBubble({Key? key, required this.message}) : super(key: key);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(pi),
            child: CustomPaint(
              painter: Triangle(Colors.grey.shade300),
            ),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: kChatBubbleBorderRadius.copyWith(
                    topLeft: const Radius.circular(8),
                    topRight: const Radius.circular(25)),
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.black, fontSize: 15),
                softWrap: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OutBubble extends StatelessWidget {
  const OutBubble({Key? key, required this.message}) : super(key: key);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.only(bottom: 5),
              decoration: const BoxDecoration(
                gradient: kMessageBubbleGradient,
                borderRadius: kChatBubbleBorderRadius,
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                softWrap: true,
              ),
            ),
          ),
          CustomPaint(painter: Triangle(const Color(0xFFFF655B))),
        ],
      ),
    );
  }
}

// Create a custom triangle
class Triangle extends CustomPainter {
  final Color backgroundColor;
  Triangle(this.backgroundColor);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = backgroundColor;

    var path = Path();
    path.lineTo(-5, 0);
    path.lineTo(0, 10);
    path.lineTo(5, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
// const BorderRadius.only(
// topRight: Radius.circular(19),
// bottomLeft: Radius.circular(19),
// bottomRight: Radius.circular(19),
// ),
