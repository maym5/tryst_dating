import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models/users.dart';
import '../field_title.dart';
import '../warning_widget.dart';

const kMaleGender = 'male';
const kFemaleGender = 'female';
const kOtherGender = "other";

class PickGenderField extends StatefulWidget {
  const PickGenderField({Key? key, this.showError = false}) : super(key: key);
  final bool showError;

  @override
  State<PickGenderField> createState() => _PickGenderFieldState();
}

class _PickGenderFieldState extends State<PickGenderField> {
  @override
  Widget build(BuildContext context) {
    return GenderField(
      showError: widget.showError && UserData.gender == null,
      maleSelected: UserData.gender == kMaleGender,
      femaleSelected: UserData.gender == kFemaleGender,
      otherSelected: UserData.gender == kOtherGender,
      title: 'Pick your Gender',
      maleOnTap: () {
        setState(() {
          UserData.gender = kMaleGender;
        });
      },
      femaleOnTap: () {
        setState(() {
          UserData.gender = kFemaleGender;
        });
      },
      onOtherTap: () {
        setState(() {
          UserData.gender = kOtherGender;
        });
      },
    );
  }
}

class PreferredGenderField extends StatefulWidget {
  const PreferredGenderField({Key? key, this.showError = false})
      : super(key: key);
  final bool showError;

  @override
  State<PreferredGenderField> createState() => _PreferredGenderFieldState();
}

class _PreferredGenderFieldState extends State<PreferredGenderField> {
  @override
  Widget build(BuildContext context) {
    return GenderField(
      showError: widget.showError && UserData.prefGender.isEmpty,
      multiplePicks: true,
      maleSelected: UserData.prefGender.contains(kMaleGender),
      femaleSelected: UserData.prefGender.contains(kFemaleGender),
      otherSelected: UserData.prefGender.contains(kOtherGender),
      title: 'Preferred Gender',
      maleOnTap: () {
        setState(() {
          UserData.prefGender.contains(kMaleGender)
              ? UserData.prefGender.remove(kMaleGender)
              : UserData.prefGender.add(kMaleGender);
        });
      },
      femaleOnTap: () {
        setState(() {
          UserData.prefGender.contains(kFemaleGender)
              ? UserData.prefGender.remove(kFemaleGender)
              : UserData.prefGender.add(kFemaleGender);
        });
      },
      onOtherTap: () {
        setState(() {
          UserData.prefGender.contains(kOtherGender)
              ? UserData.prefGender.remove(kOtherGender)
              : UserData.prefGender.add(kOtherGender);
        });
      },
    );
  }
}

class GenderField extends StatefulWidget {
  GenderField(
      {Key? key,
      required this.title,
      required this.maleOnTap,
      required this.femaleOnTap,
      required this.onOtherTap,
      this.multiplePicks = false,
      this.maleSelected = false,
      this.femaleSelected = false,
      this.otherSelected = false,
      this.showError = false})
      : super(key: key);
  final String title;
  final void Function() maleOnTap;
  final void Function() femaleOnTap;
  final void Function() onOtherTap;
  bool multiplePicks;
  bool maleSelected;
  bool femaleSelected;
  bool otherSelected;
  bool showError;
  @override
  State<GenderField> createState() => _GenderFieldState();
}

class _GenderFieldState extends State<GenderField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FieldTitle(widget.title),
        Padding(
          padding: kTileFieldPadding,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GenderButton(
                pressed: widget.maleSelected,
                gender: kMaleGender,
                onTap: () {
                  setState(() {
                    if (widget.multiplePicks) {
                      widget.maleSelected = !widget.maleSelected;
                    } else {
                      widget.maleSelected = true;
                      widget.otherSelected = false;
                      widget.femaleSelected = false;
                    }
                    widget.maleOnTap();
                  });
                },
              ),
              GenderButton(
                pressed: widget.femaleSelected,
                gender: kFemaleGender,
                onTap: () {
                  setState(() {
                    if (widget.multiplePicks) {
                      widget.femaleSelected = !widget.femaleSelected;
                    } else {
                      widget.maleSelected = false;
                      widget.otherSelected = false;
                      widget.femaleSelected = true;
                    }
                    widget.femaleOnTap();
                  });
                },
              ),
              GenderButton(
                pressed: widget.otherSelected,
                gender: kOtherGender,
                onTap: () {
                  setState(() {
                    if (widget.multiplePicks) {
                      widget.otherSelected = !widget.otherSelected;
                    } else {
                      widget.maleSelected = false;
                      widget.femaleSelected = false;
                      widget.otherSelected = true;
                    }
                    widget.onOtherTap();
                  });
                },
              )
            ],
          ),
        ),
        WarningWidget(showError: widget.showError, name: 'Gender')
      ],
    );
  }
}

class GenderButton extends StatelessWidget {
  GenderButton({
    Key? key,
    required this.gender,
    this.pressed = false,
    required this.onTap,
  }) : super(key: key) {
    _backgroundColor = pressed ? kActiveColor : kGreyWithAlpha;
    _icon = gender == kMaleGender ? Icons.male : gender == kFemaleGender ? Icons.female : Icons.transgender;
    _iconColorOpacity = pressed ? 1 : 0.6;
  }
  final String gender;
  final bool pressed;
  final void Function() onTap;
  late final Color _backgroundColor;
  late final double _iconColorOpacity;
  late final IconData _icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            _icon,
            size: 80,
            color: Colors.white.withOpacity(_iconColorOpacity),
          ),
          Text(gender.replaceFirst(gender[0], gender[0].toUpperCase()),
              style: kTextStyle.copyWith(fontSize: 18))
        ],
      ),
      style: ButtonStyle(
        alignment: Alignment.center,
        fixedSize:
            MaterialStateProperty.resolveWith((states) => kGenderButtonSize),
        shape:
            MaterialStateProperty.resolveWith((states) => const CircleBorder()),
        backgroundColor:
            MaterialStateProperty.resolveWith((states) => _backgroundColor),
      ),
    );
  }
}
