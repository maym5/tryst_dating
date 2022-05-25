import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/dialogues/log_out_dialogue.dart';
import 'package:rendezvous_beta_v3/widgets/gradient_button.dart';

import '../constants.dart';

class DateTimeDialogue extends StatelessWidget {
  // TODO: build a congrats dialogue too to display the date
  const DateTimeDialogue({Key? key, required this.setDateTime})
      : super(key: key);
  final void Function(DateTime date, TimeOfDay time) setDateTime;

  bool _decideWhichDaysToEnable(DateTime day) {
    // if it is after yesterday: okay
    final DateTime now = DateTime.now();
    final bool isAfterYesterday =
        day.isAfter(now.subtract(const Duration(days: 1)));
    final bool isWithinTwoWeeks =
        day.isBefore(now.add(const Duration(days: 14)));
    if (isAfterYesterday && isWithinTwoWeeks) {
      return true;
    }
    return false;
  }

  Future<void> buildCalendarDialogue(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
        selectableDayPredicate: _decideWhichDaysToEnable,
        helpText: "Pick a day for the date",
        confirmText: "Next",
        context: context,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
                dialogBackgroundColor: kPopUpColor,
                textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(primary: Colors.redAccent))),
            child: child!,
          );
        },
        initialDate: now,
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 1));

    // TODO: find a way to keep user from selecting hour the place isnt open
    final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialEntryMode: TimePickerEntryMode.input,
        helpText: "Pick a time for your date",
        confirmText: "Ask out",
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
                dialogBackgroundColor: kPopUpColor,
                textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(primary: Colors.redAccent))),
            child: child!,
          );
        },
        initialTime: TimeOfDay.now());

    if (pickedTime != null && picked != null) {
      setDateTime(picked, pickedTime);
    }


  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// class CongratsDialogue extends StatelessWidget {
//   const CongratsDialogue(
//       {Key? key, required this.matchName, required this.setDateTime, required this.venueName})
//       : super(key: key);
//   final String matchName;
//   final void Function(DateTime date, TimeOfDay time) setDateTime;
//   final String venueName;
//
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text("Congrats you've got a date with $matchName at $venueName!",
//           softWrap: true,
//           style: kTextStyle.copyWith(fontSize: 20),
//       ),
//       actions: [
//         GradientButton(
//           title: "Pick a time!",
//           onPressed: () {
//             DateTimeDialogue(setDateTime: setDateTime)
//                 .buildCalendarDialogue(context);
//           },
//         ),
//         GradientButton(
//             title: "Nah, I'll pass",
//             onPressed: () {
//               Navigator.pop(context);
//             },
//         )
//       ],
//     );
//   }
// }

class CongratsDialogue2 extends StatelessWidget {
  const CongratsDialogue2({Key? key, required this.animation, required this.venueName, required this.matchName, required this.setDateTime}) : super(key: key);
  final Animation<double> animation;
  final String matchName;
  final String venueName;
  final void Function(DateTime date, TimeOfDay time) setDateTime;

  @override
  Widget build(BuildContext context) => buildPopUpDialogue(animation, context,
      children: [
        Text("Congrats you've got a date with $matchName at $venueName!",
          softWrap: true,
          style: kTextStyle.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 10),
        GradientButton(
          title: "Pick a time!",
          onPressed: () {
            Navigator.pop(context);
            DateTimeDialogue(setDateTime: setDateTime)
                .buildCalendarDialogue(context);
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

