import 'package:flutter/material.dart';

import '../../cloud/users.dart';
import '../../constants.dart';
import '../field_title.dart';
import '../warning_widget.dart';


class PricePicker extends StatefulWidget {
  const PricePicker({Key? key, required this.showError}) : super(key: key);
  final bool showError;

  @override
  State<PricePicker> createState() => _PricePickerState();
}

class _PricePickerState extends State<PricePicker>
    with AutomaticKeepAliveClientMixin {
  late bool _hasMoved;
  Color get _activeColor => _hasMoved ? kActiveColor : kInactiveColor;
  RangeValues _values = const RangeValues(2, 3);

  @override
  void initState() {
    _hasMoved = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        const FieldTitle("What's your price range"),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: priceIcons,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Theme(
            data: ThemeData(
              sliderTheme: kSliderTheme.copyWith(
                  activeTrackColor: _activeColor,
                  thumbColor: _activeColor,
                  activeTickMarkColor: _activeColor),
            ),
            child: RangeSlider(
              values: _values,
              onChanged: (rangeValues) {
                setState(() {
                  _values = rangeValues;
                  _hasMoved = true;
                  UserData.minPrice = rangeValues.start.toInt();
                  UserData.maxPrice = rangeValues.end.toInt();
                  // priceIcons(); // da fuk you doing here
                });
              },
              min: 1,
              max: 4,
              divisions: 3,
            ),
          ),
        ),
        WarningWidget(
            showError: widget.showError &&
                UserData.maxPrice == null &&
                UserData.minPrice == null,
            name: "PricePicker")
      ],
    );
  }

  List<Widget> get priceIcons {
    List<Widget> icons = [];
    for (int i = 1; i <= 4; i++) {
      icons.add(Expanded(
        child: Text('\$' * i,
            textAlign: TextAlign.center,
            style: kTextStyle.copyWith(
                color: i >= _values.start && i <= _values.end && _hasMoved
                    ? kActiveColor
                    : kInactiveColor)),
      ));
    }
    return icons;
  }

  @override
  bool get wantKeepAlive => _hasMoved;
}
