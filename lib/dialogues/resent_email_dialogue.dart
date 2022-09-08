import "package:flutter/material.dart";
import 'package:rendezvous_beta_v3/dialogues/log_out_dialogue.dart';
import 'package:rendezvous_beta_v3/widgets/gradient_button.dart';

class ResentEmailDialogue extends StatelessWidget {
  const ResentEmailDialogue({Key? key, required this.animation}) : super(key: key);
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => buildPopUpDialogue(
      animation,
      context,
      children: [
        const Text("We resent that email!",
            textAlign: TextAlign.center,
            style: TextStyle(
            color: Colors.redAccent,
            fontSize: 25
        )),
        const SizedBox(
          height: 50,
        ),
        GradientButton(title: "Okay!", onPressed: () {
          Navigator.pop(context);
        })
      ]
  );
}
