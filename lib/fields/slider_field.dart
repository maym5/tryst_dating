import "package:flutter/material.dart";
import '../cloud_functions/users.dart';
import '../constants.dart';
import '../layouts/field_title.dart';
import '../widgets/warning_widget.dart';

class AgeSlider extends StatelessWidget {
  const AgeSlider({Key? key, required this.showError}) : super(key: key);
  final bool showError;

  @override
  Widget build(BuildContext context) {
    return SliderField(
      title: "Age",
      max: 40,
      min: 18,
      initialValue: UserData.age ?? 21,
      showError: showError && UserData.age == null,
      onChangeEnd: (age) {
        UserData.age = age.toInt();
      },
    );
  }
}

class DistanceSlider extends StatelessWidget {
  const DistanceSlider({Key? key, required this.showError}) : super(key: key);
  final bool showError;

  @override
  Widget build(BuildContext context) {
    return SliderField(
        title: "Distance",
        units: "Miles",
        initialValue:
            UserData.maxDistance != null ? UserData.maxDistance!.toInt() : 5,
        showError: showError && UserData.maxDistance == null,
        onChangeEnd: (distance) {
          UserData.maxDistance = distance.toInt();
        },
        max: 25,
        min: 1);
  }
}

class PreferredAgeSlider extends StatelessWidget {
  const PreferredAgeSlider({Key? key, required this.showError})
      : super(key: key);
  final bool showError;

  int get _min => UserData.minAge ?? 22;
  int get _max => UserData.maxAge ?? 25;

  @override
  Widget build(BuildContext context) {
    return RangeSliderField(
        title: "Preferred Age",
        showError: showError && UserData.minAge == null && UserData.maxAge == null,
        initialValues: RangeValues(_min.toDouble(), _max.toDouble()),
        onChangeEnd: (preferredAges) {
          UserData.minAge = preferredAges.start.toInt();
          UserData.maxAge = preferredAges.end.toInt();
        },
        max: 40,
        min: 18);
  }
}

class SliderField extends StatefulWidget {
  const SliderField(
      {Key? key,
      required this.title,
      required this.initialValue,
      required this.onChangeEnd,
      required this.showError,
      required this.max,
      required this.min,
        this.onChanged,
      this.units = ""})
      : super(key: key);
  final String title;
  final int initialValue;
  final void Function(double) onChangeEnd;
  final bool showError;
  final int min;
  final int max;
  final String units;
  final void Function()? onChanged;

  @override
  _SliderFieldState createState() => _SliderFieldState();
}

class _SliderFieldState extends State<SliderField>
    with AutomaticKeepAliveClientMixin {
  late double _sliderValue;
  late bool _hasMoved;

  Color get _activeColor => _hasMoved ? kActiveColor : kInactiveColor;

  String get _displayedValue => _sliderValue.round().toString() + ' ' + widget.units;

  @override
  void initState() {
    _sliderValue = widget.initialValue.toDouble();
    _hasMoved = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Have to call super.build for AutomaticKeepAliveClientMixin
    super.build(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        FieldTitle(
          widget.title + ': ' + _displayedValue,
        ),
        Theme(
          data: ThemeData(
              sliderTheme: kSliderTheme.copyWith(
                  activeTrackColor: _activeColor, thumbColor: _activeColor)),
          child: Slider(
            value: _sliderValue,
            min: widget.min.toDouble(),
            max: widget.max.toDouble(),
            onChanged: (double value) {
              setState(() {
                _sliderValue = value;
                _hasMoved = true;
                if (widget.onChanged != null) {
                  widget.onChanged!();
                }
              });
            },
            onChangeEnd: widget.onChangeEnd,
          ),
        ),
        WarningWidget(showError: widget.showError && !_hasMoved, name: widget.title),
      ],
    );
  }

  /* Comes from AutomaticKeepAliveClientMixin.
  * Using this to keep flutter from disposing of the widget
  * If the user has moved the slider but the slider is no longer on screen (user scrolled).
  * This prevents the color from being reset to
  * grey when it is reinserted (they scroll back).
  * UserData persists the values displayed but not the color */
  @override
  bool get wantKeepAlive => _hasMoved;
}

class RangeSliderField extends StatefulWidget {
  const RangeSliderField({
    Key? key,
    required this.title,
    required this.initialValues,
    required this.showError,
    required this.onChangeEnd,
    required this.min,
    required this.max,
  }) : super(key: key);
  final String title;
  final RangeValues initialValues;
  final bool showError;
  final void Function(RangeValues) onChangeEnd;
  final int min;
  final int max;

  @override
  State<RangeSliderField> createState() => _RangeSliderFieldState();
}

class _RangeSliderFieldState extends State<RangeSliderField>
    with AutomaticKeepAliveClientMixin {
  late RangeValues _values;
  late bool _hasMoved;

  Color get _activeColor => _hasMoved ? kActiveColor : kInactiveColor;

  String get _displayedValue => _values.start.round().toString() + "-" + _values.end.round().toString();

  @override
  void initState() {
    _values = widget.initialValues;
    _hasMoved = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        FieldTitle(
          widget.title + ': ' + _displayedValue,
        ),
        Theme(
          data: ThemeData(
              sliderTheme: kSliderTheme.copyWith(
                  activeTrackColor: _activeColor, thumbColor: _activeColor)),
          child: RangeSlider(
            values: _values,
            min: widget.min.toDouble(),
            max: widget.max.toDouble(),
            onChanged: (RangeValues values) {
              setState(() {
                _values = values;
                _hasMoved = true;
              });
            },
            onChangeEnd: widget.onChangeEnd,
          ),
        ),
        WarningWidget(
          showError: widget.showError && !_hasMoved,
          name: widget.title,
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => _hasMoved;
}
