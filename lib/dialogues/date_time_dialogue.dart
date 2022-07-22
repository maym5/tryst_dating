import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/dialogues/log_out_dialogue.dart';
import 'package:rendezvous_beta_v3/dialogues/pick_another_day_dialogue.dart';
import 'package:rendezvous_beta_v3/widgets/gradient_button.dart';
import '../constants.dart';

class DateTimeDialogue extends StatelessWidget {
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

  Future<void> buildCalendarDialogue(BuildContext context,
      {required String venueName,
      required String matchName,
      bool pickAnother = false,
        bool initialDialogue = true,
      }) async {
    initialDialogue ? await showGeneralDialog(
        context: context,
        pageBuilder: (context, animation, _) => pickAnother
            ? PickAnotherDayDialogue(animation: animation, venueName: venueName)
            : CongratsDialogue(
                animation: animation,
                venueName: venueName,
                matchName: matchName)) : null;

    final DateTime now = DateTime.now();

    DateTime? picked;
    TimeOfDay? pickedTime;

    if (Platform.isIOS) {
      await showCupertinoModalPopup(
          context: context,
          builder: (context) => Center(
            child: Container(
              color: Colors.white,
                  height: 300,
                  width: 300,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 220,
                        width: 300,
                        child: CupertinoDatePicker(
                            use24hFormat: true,
                            initialDateTime: now,
                            maximumYear: 3000,
                            minimumYear: 2000,
                            mode: CupertinoDatePickerMode.date,
                            onDateTimeChanged: (dateTime) {
                              picked = dateTime;
                            }),
                      ),
                      CupertinoButton(
                          child: const Text("Pick time"),
                          onPressed: () {
                            Navigator.pop(context);
                          }
                      )
                    ],
                  ),
                ),
          ));
      await showCupertinoModalPopup(
          context: context,
          builder: (context) => Center(
            child: Container(
              color: Colors.white,
                  height: 300,
                  width: 300,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 220,
                        width: 300,
                        child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.time,
                            onDateTimeChanged: (dateTime) {
                              pickedTime = TimeOfDay(
                                  hour: dateTime.hour, minute: dateTime.minute);
                            }),
                      ),
                      CupertinoButton(
                          child: const Text("DONE"),
                          onPressed: () {
                            Navigator.pop(context);
                          }
                      ),
                    ],
                  )
                ),
          ));
    } else {
      picked = await showDatePicker(
          selectableDayPredicate: _decideWhichDaysToEnable,
          helpText: "Pick a day for the date",
          confirmText: "Next",
          context: context,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                  dialogBackgroundColor: kPopUpColor,
                  colorScheme: kPopUpColorScheme,
                  textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(primary: Colors.redAccent))),
              child: child!,
            );
          },
          initialDate: now,
          firstDate: DateTime(now.year - 1),
          lastDate: DateTime(now.year + 1));

      pickedTime = await showTimePicker(
          context: context,
          helpText: "Pick a time for your date",
          confirmText: "Ask out",
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                  dialogBackgroundColor: kDarkTransparent,
                  colorScheme: kPopUpColorScheme,
                  textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(primary: Colors.redAccent))),
              child: child!,
            );
          },
          initialTime: TimeOfDay.now());
    }

    if (pickedTime != null && picked != null) {
      setDateTime(picked!, pickedTime!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class CongratsDialogue extends StatelessWidget {
  const CongratsDialogue(
      {Key? key,
      required this.animation,
      required this.venueName,
      required this.matchName})
      : super(key: key);
  final Animation<double> animation;
  final String matchName;
  final String venueName;

  @override
  Widget build(BuildContext context) => buildPopUpDialogue(
        animation,
        context,
        height: 400,
        children: [
          Text(
            "Congrats you've got a date with $matchName at $venueName!",
            softWrap: true,
            textAlign: TextAlign.center,
            style: kTextStyle.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 10),
          GradientButton(
            title: "Pick a time!",
            onPressed: () {
              Navigator.of(context).pop();
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
