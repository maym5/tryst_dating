import 'package:flutter/material.dart';
import '../animations/fade_in_animation.dart';
import '../constants.dart';

class TileCard extends StatelessWidget {
  const TileCard({Key? key, required this.child, this.padding = kTilePadding}) : super(key: key);
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return FadeInAnimation(
      child: Card(
        elevation: 25,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        color: kTileBackGroundColor,
        surfaceTintColor: const Color(0xFF404E5F),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
