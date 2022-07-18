import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/dialogues/log_out_dialogue.dart';
import '../constants.dart';
import '../widgets/gradient_button.dart';

class ErrorDialogue extends StatelessWidget {
  const ErrorDialogue({Key? key, required this.animation}) : super(key: key);
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => buildPopUpDialogue(
      animation,
      context,
      children: [
        Text("There was an error, that's on us. Try again and we're sure it'll work",
          softWrap: true,
          textAlign: TextAlign.center,
          style: kTextStyle.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 10),
        GradientButton(
          title: "Okay",
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
  );
}
