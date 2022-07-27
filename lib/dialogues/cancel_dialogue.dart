import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/dialogues/log_out_dialogue.dart';
import '../constants.dart';
import '../widgets/gradient_button.dart';

class CancelDialogue extends StatelessWidget {
  const CancelDialogue({Key? key, required this.animation}) : super(key: key);
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => buildPopUpDialogue(
      animation,
      context,
      children: [
        Text("Sorry to see you canceled, but they didn't deserve you anyway",
          softWrap: true,
          textAlign: TextAlign.center,
          style: kTextStyle.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 10),
        GradientButton(
          title: "Hell yeah",
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
  );
}
