import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/dialogues/date_time_dialogue.dart';
import 'package:rendezvous_beta_v3/dialogues/log_out_dialogue.dart';

import '../constants.dart';
import '../widgets/gradient_button.dart';

class PickAnotherDayDialogue extends StatelessWidget {
  const PickAnotherDayDialogue(
      {Key? key,
      required this.animation,
      required this.venueName,
      required this.openHours,
      required this.setDateTime,
      required this.matchName,
      required this.setYesOrNo})
      : super(key: key);
  final Animation<double> animation;
  final String venueName;
  final List openHours;
  final void Function(DateTime, TimeOfDay) setDateTime;
  final String matchName;
  final void Function(bool) setYesOrNo;

  Widget get _openText {
    final List<Text> children = [];
    for (String dayText in openHours) {
      children.add(Text(dayText, style: kTextStyle.copyWith(fontSize: 17)));
    }
    return Column(
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) => buildPopUpDialogue(
        animation,
        context,
        height: 600,
        children: [
          Text(
            "Sorry! $venueName is closed at the time selected, please select another time! Here's when $venueName is open",
            softWrap: true,
            textAlign: TextAlign.center,
            style: kTextStyle.copyWith(fontSize: 20),
          ),
          SizedBox(
              child: FittedBox(child: _openText, fit: BoxFit.scaleDown),
              height: 200),
          const SizedBox(height: 10),
          GradientButton(
            title: "Pick a time!",
            onPressed: () {
              setYesOrNo(true);
              Navigator.pop(context);
              // DateTimeDialogue(setDateTime: setDateTime).buildCalendarDialogue(
              //     context,
              //     pickAnother: false,
              //     initialDialogue: false,
              //     venueName: venueName,
              //     matchName: matchName,
              //     openHours: openHours);
              // put the dialogue here
            },
          ),
          const SizedBox(height: 10),
          GradientButton(
            title: "Nah, I'll pass",
            onPressed: () {
              setYesOrNo(false);
              Navigator.pop(context);
            },
          )
        ],
      );
}
