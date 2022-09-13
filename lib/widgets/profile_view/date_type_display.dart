import 'package:flutter/material.dart';
import '../../constants.dart';

class DateTypeDisplay extends StatelessWidget {
  const DateTypeDisplay({Key? key, required this.dateTypes}) : super(key: key);
  final List<String> dateTypes;

  List<String> get titles {
    List<String> titles = [];
    for (String dateType in dateTypes) {
      if (dateType.contains(RegExp(r'[A-Z]'))) {
        // found crazy RegExp on stack overflow;;;dark magic;;;
        var result = dateType.replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), r" ");
        var finalResult = result[0].toUpperCase() + result.substring(1);
        titles.add(finalResult);
      } else {
        titles
            .add(dateType.replaceFirst(dateType[0], dateType[0].toUpperCase()));
      }
    }
    return titles;
  }

  double get _heightFactor {
    int numberOfRows = (titles.length / 3).ceil();
    return 0.1 + (.04 * numberOfRows);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: kUserInfoAlignment,
      child: FractionallySizedBox(
        widthFactor: 0.7,
        heightFactor: _heightFactor,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: titles.length,
            gridDelegate: kDateTypeGridDelegate,
            itemBuilder: (BuildContext context, int index) => DateTypeContainer(title: titles[index]),
        ),
      ),
    );
  }
}

class DateTypeContainer extends StatelessWidget {
  const DateTypeContainer({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kDateTypeContainerDecoration,
      child: Center(
          child: Text(
            title,
            style: kTextStyle.copyWith(fontSize: 15, color: Colors.white),
            textAlign: TextAlign.center,
            softWrap: true,
          )),
    );
  }
}

