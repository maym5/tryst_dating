import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/animations/fade_in_animation.dart';


class TextFadeIn extends StatelessWidget {
  const TextFadeIn({Key? key, required this.text, this.style})
      : super(key: key);
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    int delay = 500;
    for (String char in text.characters) {
      final Text _text = Text(char, style: style);
      final Widget _animatedText = FadeInAnimation(
          child: _text, delay: delay, duration: const Duration(seconds: 1), verticalOffset: -0.35);
      children.add(_animatedText);
      delay += 100;
    }
    return Row(
      children: children,
      mainAxisSize: MainAxisSize.min,
    );
  }
}
