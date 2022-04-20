import 'package:flutter/material.dart';

import '../constants.dart';

class FieldTitle extends StatelessWidget {
  const FieldTitle(this.title,
      {Key? key, this.padding = kTileTitlePadding})
      : super(key: key);
  final String title;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title,
        softWrap: true,
        textAlign: TextAlign.center,
        style: kTextStyle,
      ),
    );
  }
}
