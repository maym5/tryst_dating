import 'package:flutter/material.dart';

class PhotoBar extends StatelessWidget {
  const PhotoBar({Key? key, required this.activeIndex, required this.length}) : super(key: key);
  final int activeIndex;
  final int length;

  Widget photoBarDot(Color color) => Container(
    height: 10.0,
    width: 10.0,
    decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color
    ),
  );

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (int i = 0; i < length; i++) {
      if (i == activeIndex) {
        children.add(photoBarDot(Colors.white));
      } else {
        children.add(photoBarDot(Colors.grey));
      }
      children.add(const SizedBox(width: 5));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children
    );
  }
}
