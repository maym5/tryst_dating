import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/dialogues/log_out_dialogue.dart';
import 'package:rendezvous_beta_v3/dialogues/pick_another_day_dialogue.dart';
import 'package:rendezvous_beta_v3/widgets/gradient_button.dart';
import '../constants.dart';

class DateTimeDialogue extends StatelessWidget {
  DateTimeDialogue({Key? key, required this.setDateTime}) : super(key: key);
  final void Function(DateTime date, TimeOfDay time) setDateTime;
  bool yesOrNo = false;

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

  void _setYesOrNo(bool input) {
    yesOrNo = input;
  }

  Future<void> buildCalendarDialogue(
    BuildContext context, {
    required String venueName,
    required String matchName,
    required List openHours,
    bool pickAnother = false,
    bool initialDialogue = true,
  }) async {
    initialDialogue
        ? await showGeneralDialog(
            context: context,
            pageBuilder: (context, animation, _) => pickAnother
                ? PickAnotherDayDialogue(
                    animation: animation, venueName: venueName, openHours: openHours)
                : CongratsDialogue(
                    openHours: openHours,
                    animation: animation,
                    venueName: venueName,
                    matchName: matchName,
                    yesOrNo: _setYesOrNo,
                  ))
        : null;

    final DateTime now = DateTime.now();

    DateTime? picked;
    TimeOfDay? pickedTime;

    if (Platform.isIOS && yesOrNo == true) {
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
                          })
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
                              minuteInterval: 5,
                              initialDateTime: now.add(Duration(minutes: 5 - now.minute % 5)),
                              mode: CupertinoDatePickerMode.time,
                              onDateTimeChanged: (dateTime) {
                                pickedTime = TimeOfDay(
                                    hour: dateTime.hour,
                                    minute: dateTime.minute);
                              }),
                        ),
                        CupertinoButton(
                            child: const Text("DONE"),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      ],
                    )),
              ));
    } else if (Platform.isAndroid && yesOrNo == true) {
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
  // TODO: pass a function so we know if they said yes or no
  const CongratsDialogue(
      {Key? key,
      required this.animation,
      required this.venueName,
      required this.matchName,
      required this.openHours, this.yesOrNo})
      : super(key: key);
  final Animation<double> animation;
  final String matchName;
  final String venueName;
  final List openHours;
  final void Function(bool)? yesOrNo;

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
            "Congrats you've got a date with $matchName at $venueName!",
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
              yesOrNo!(true);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 10),
          GradientButton(
            title: "Nah, I'll pass",
            onPressed: () {
              yesOrNo!(false);
              Navigator.pop(context);
            },
          )
        ],
      );
}
