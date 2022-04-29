import "package:flutter/material.dart";
import '../../constants.dart';
import '../../models/users.dart';
import '../field_title.dart';
import '../warning_widget.dart';

class DateButton extends StatelessWidget {
  const DateButton(
      {Key? key,
      required this.pressed,
      required this.onPressed,
      required this.dateIcon,
      required this.dateName})
      : super(key: key);
  final bool pressed;
  final void Function() onPressed;
  final IconData dateIcon;
  final String dateName;

  Color get _borderColor => pressed ? kOffWhite : kGreyWithAlpha;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: 120,
      child: MaterialButton(
        onPressed: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(dateIcon, size: 30, color: kOffWhite),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                dateName,
                style: kTextStyle.copyWith(fontSize: 15),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
        color: kGreyWithAlpha,
        shape: CircleBorder(side: BorderSide(color: _borderColor, width: 4)),
      ),
    );
  }
}

class DateTypePicker extends StatefulWidget {
  const DateTypePicker({Key? key, required this.showError}) : super(key: key);
  final bool showError;

  @override
  _DateTypePickerState createState() => _DateTypePickerState();
}

class _DateTypePickerState extends State<DateTypePicker> {


  late final Map<String, List> _buttonData = {
    // first item in value list is the bool which controls the button's highlight color
    // second item is the icon for the button
    // the third is the button title
    "artGallery": [
      UserData.dates.contains("artGallery"),
      Icons.brush,
      "Art Gallery"
    ],
    "bakery": [
      UserData.dates.contains("bakery"),
      Icons.bakery_dining,
      "Bakery"
    ],
    "bar": [UserData.dates.contains("bar"), Icons.local_bar, "Bar"],
    "bowlingAlley": [
      UserData.dates.contains("bowlingAlley"),
      Icons.album_rounded,
      "Bowling Alley"
    ],
    "cafe": [UserData.dates.contains("cafe"), Icons.local_cafe_sharp, "Café"],
    "museum": [
      UserData.dates.contains("museum"),
      Icons.museum_rounded,
      "Museum"
    ],
    "nightClub": [
      UserData.dates.contains("nightClub"),
      Icons.music_note_outlined,
      "Night Club"
    ],
    "park": [UserData.dates.contains("park"), Icons.park, "Park"],
    'restaurant': [
      UserData.dates.contains("restaurant"),
      Icons.restaurant,
      "Restaurant"
    ],
  };

  void _onPressed(String buttonDataKey) {
    setState(() {
      _buttonData[buttonDataKey]![0] = !_buttonData[buttonDataKey]![0];
      if (_buttonData[buttonDataKey]![0]) {
        UserData.dates.add(buttonDataKey);
      } else {
        UserData.dates.remove(buttonDataKey);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<DateButton> dateButtons = [];
    for (String key in _buttonData.keys) {
      dateButtons.add(
        DateButton(
          pressed: _buttonData[key]![0],
          onPressed: () {
            _onPressed(key);
          },
          dateIcon: _buttonData[key]![1],
          dateName: _buttonData[key]![2],
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const FieldTitle("How do you want to Rendezvous?"),
        Padding(
          padding: kWrapPadding,
          child: Wrap(
            children: dateButtons,
            runSpacing: 12,
            spacing: 12,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
          ),
        ),
        WarningWidget(
            showError: widget.showError && UserData.dates.isEmpty,
            name: "date picker")
      ],
    );
  }
}
