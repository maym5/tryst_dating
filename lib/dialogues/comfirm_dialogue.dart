import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/gradient_button.dart';
import 'log_out_dialogue.dart';
import 'package:intl/intl.dart';

class ConfirmDialogue extends StatelessWidget {
  ConfirmDialogue(
      {Key? key,
        required this.dateTime,
        required this.venueName,
        required this.animation,
        required this.matchName})
      : super(key: key);
  final Animation<double> animation;
  final String matchName;
  final String venueName;
  final DateTime dateTime;
  final DateFormat formatter = DateFormat('EEEE, d MMMM, h:mm a');

  String get _displayedDateTime => formatter.format(dateTime);

  @override
  Widget build(BuildContext context) =>
      buildPopUpDialogue(animation, context, height: 400, children: [
        Text(
          "We asked $matchName out to $venueName at $_displayedDateTime, we'll let you know what they say!",
          softWrap: true,
          textAlign: TextAlign.center,
          style: kTextStyle.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 10),
        GradientButton(
          title: "Okay",
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ]);
}