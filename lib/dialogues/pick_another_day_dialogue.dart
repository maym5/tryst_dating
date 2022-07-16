import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/dialogues/log_out_dialogue.dart';

import '../constants.dart';
import '../widgets/gradient_button.dart';

class PickAnotherDayDialogue extends StatelessWidget {
  const PickAnotherDayDialogue({Key? key, required this.animation, required this.venueName}) : super(key: key);
  final Animation<double> animation;
  final String venueName;


  @override
  Widget build(BuildContext context) => buildPopUpDialogue(
      animation,
      context,
      height: 400,
      children: [
        Text("Sorry! $venueName is closed at the time selected, please select another time!",
          softWrap: true,
          textAlign: TextAlign.center,
          style: kTextStyle.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 10),
        GradientButton(
          title: "Pick a time!",
          onPressed: () {
            Navigator.of(context).pop();
            // put the dialogue here
          },
        ),
        const SizedBox(height: 10),
        GradientButton(
          title: "Nah, I'll pass",
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
  );
}
