import 'package:flutter/material.dart';

import '../constants.dart';

class DateTimeDialogue extends StatelessWidget {
  const DateTimeDialogue({Key? key, required this.setDateTime}) : super(key: key);
  final void Function(DateTime date, TimeOfDay time) setDateTime;

  bool _decideWhichDaysToEnable(DateTime day) {
    // if it is after yesterday: okay
    final DateTime now = DateTime.now();
    final bool isAfterYesterday = day.isAfter(now.subtract(const Duration(days: 1)));
    final bool isWithinTwoWeeks = day.isBefore(now.add(const Duration(days: 14)));
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

    final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
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
