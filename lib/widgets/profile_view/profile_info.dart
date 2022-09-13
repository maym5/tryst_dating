import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:expandable_text/expandable_text.dart';

import '../../constants.dart';
import 'date_type_display.dart';

class ProfileInfo extends StatelessWidget {
  const ProfileInfo(
      {Key? key,
      required this.age,
      required this.name,
      required this.bio,
      required this.onExpand,
      required this.activeIndex,
      required this.dateTypes, required this.tapUp, required this.tapDown,
      })
      : super(key: key);
  final String name;
  final int age;
  final String bio;
  final void Function(bool) onExpand;
  final int activeIndex;
  final List<String> dateTypes;
  final void Function(TapUpDetails) tapUp;
  final void Function(TapDownDetails) tapDown;

  @override
  Widget build(BuildContext context) {
    if (activeIndex == 0) {
      return Align(
        alignment: kUserInfoAlignment,
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              NameAndAge(name: name, age: age),
              Bio(bio: bio, onExpand: onExpand)
            ],
          ),
        ),
      );
    } else if (activeIndex == 1) {
      return GestureDetector(
          child: DateTypeDisplay(dateTypes: dateTypes),
        onTapUp: tapUp,
        onTapDown: tapDown,
      );
    } return Container();
  }
}

class NameAndAge extends StatelessWidget {
  const NameAndAge({Key? key, required this.name, required this.age, this.padding})
      : super(key: key);
  final String name;
  final int age;
  final EdgeInsetsGeometry? padding;

  Widget getText(String text) => Padding(
        padding: padding ?? kProfileInfoPadding,
        child: Text(
          text,
          style: text == name ? kNameTextStyle : kAgeTextStyle,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          getText(name),
          getText(age.toString()),
        ],
      ),
    );
  }
}

class Bio extends StatefulWidget {
  const Bio({Key? key, required this.bio, required this.onExpand})
      : super(key: key);
  final String bio;
  final void Function(bool) onExpand;

  @override
  _BioState createState() => _BioState();
}

class _BioState extends State<Bio> with TickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _controller;
  late Animation<Offset> _animOffset;

  @override
  void initState() {
    _expanded = false;
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200)); // move the const's
    _animOffset =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, -0.4))
            .animate(_controller);
    super.initState();
  }

  Widget backdropFilter({required Widget child}) => BackdropFilter(
      filter: ImageFilter.blur(
          sigmaX: _expanded ? 10 : 0, sigmaY: _expanded ? 10 : 0),
      child: child);

  void _onBioTap(bool expanded) {
    setState(() => _expanded = expanded);
    if (expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    widget.onExpand(expanded);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kBioPadding,
      child: backdropFilter(
        child: SlideTransition(
          position: _animOffset,
          child: ExpandableText(
            widget.bio,
            onExpandedChanged: _onBioTap,
            expandText: "",
            linkColor: kActiveColor,
            maxLines: 2,
            expandOnTextTap: true,
            linkEllipsis: false,
            collapseOnTextTap: true,
            animationDuration: kExpandTextAnimationDuration,
            animationCurve: Curves.linear,
            animation: true,
            style: kBioTextStyle,
          ),
        ),
      ),
    );
  }
}
