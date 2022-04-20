import "package:flutter/material.dart";

import '../constants.dart';

class WarningWidget extends StatelessWidget {
  const WarningWidget(
      {Key? key,
      required this.showError,
      required this.name,
      this.errorMessage})
      : super(key: key);
  final bool showError;
  final String? errorMessage;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: showError,
      child: FittedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.warning_amber_outlined,
              color: kActiveColor,
              size: 25,
            ),
            Text(
              errorMessage == null ? ' Please fill in the $name field'
                  : ' ' + errorMessage!,
              style: kWarningTextStyle
            ),
          ],
        ),
      ),
    );
  }
}
