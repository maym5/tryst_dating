import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/animations/bounce_animation.dart';
import 'package:rendezvous_beta_v3/services/match_data_service.dart';
import 'package:rendezvous_beta_v3/widgets/profile_view/profile_info.dart';

import '../dialogues/date_time_dialogue.dart';
import '../models/users.dart';
import '../services/google_places_service.dart';

class MatchTile extends StatefulWidget {
  const MatchTile({Key? key, required this.data}) : super(key: key);
  final MatchCardData data;

  @override
  State<MatchTile> createState() => _MatchTileState();
}

class _MatchTileState extends State<MatchTile> with TickerProviderStateMixin {
  DateTime? _dateTime;
  late bool _beenTapped;
  late final AnimationController _controller;

  // List? _commonDates = widget.data.dateTypes
  //     ?.where((element) => UserData.dates.contains(element))
  //     .toList();
  // if (_commonDates != null) {
  // print("have common dates");
  // final _dateType =
  // _commonDates[Random().nextInt(_commonDates.length)];
  // final Map _venue =
  // await GooglePlacesService(venueType: _dateType).venue;
  // // deal with google places edge cases
  // print(_venue["status"]);
  // if (_venue["status"] == "OK") {
  // print("venue status OK");
  // // TODO: if they dismiss dialogue dont show calendar and clock
  // await DateTimeDialogue(setDateTime: _setDateTime)
  //     .buildCalendarDialogue(context,
  // venueName: _venue["name"], matchName: widget.data.name);
  // final _isOpen = await GooglePlacesService.checkDateTime(
  // _dateTime!, _venue);
  // if (_dateTime != null && _isOpen) {
  // print("date time is alright");
  // await MatchDataService.updateMatchData(
  // otherUserUID: widget.data.matchID,
  // dateType: _dateType,
  // dateTime: _dateTime!,
  // venue: _venue["name"]);
  // print("added data to firebase");

  void _setDateTime(DateTime date, TimeOfDay time) {
    setState(() {
      _dateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _controller.forward();
    });
  }

  void _onTapUp(TapUpDetails details) async {
    setState(() {
      _controller.reverse();
    });
    List? _commonDates = widget.data.dateTypes
        ?.where((element) => UserData.dates.contains(element))
        .toList();
    if (_commonDates != null) {
      print("have common dates");
      final _dateType = _commonDates[Random().nextInt(_commonDates.length)];
      final Map _venue = await GooglePlacesService(venueType: _dateType).venue;
      // deal with google places edge cases
      print(_venue["status"]);
      if (_venue["status"] == "OK") {
        print("venue status OK");
        // TODO: if they dismiss dialogue dont show calendar and clock
        await DateTimeDialogue(setDateTime: _setDateTime).buildCalendarDialogue(
            context,
            venueName: _venue["name"],
            matchName: widget.data.name);
        final _isOpen =
            await GooglePlacesService.checkDateTime(_dateTime!, _venue);
        if (_dateTime != null && _isOpen) {
          print("date time is alright");
          await MatchDataService.updateMatchData(
              otherUserUID: widget.data.matchID,
              dateType: _dateType,
              dateTime: _dateTime!,
              venue: _venue["name"]);
          print("added data to firebase");
        } else if (!_isOpen) {
          setState(() {
            _beenTapped = false;
          });
          // do a pop up
        } else {
          // do a pop up
          setState(() {
            _beenTapped = false;
          });
        }
      }
    } else {
      setState(() {
        // do a pop up
        _beenTapped = false;
      });
    }
  }

  Widget get _nameAndAge => Align(
      child: Padding(
        child: NameAndAge(
          name: widget.data.name,
          age: widget.data.age!,
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        ),
        padding: const EdgeInsets.only(bottom: 15),
      ),
      alignment: Alignment.bottomLeft);

  Widget get _backgroundImage => ClipRRect(
        child: Image.network(widget.data.image!, fit: BoxFit.cover),
        borderRadius: BorderRadius.circular(25),
      );

  Widget get _stack => Stack(
        fit: StackFit.expand,
        children: [_backgroundImage, _nameAndAge],
      );

  @override
  void initState() {
    _beenTapped = false;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: check edge cases on this visibility
    return Visibility(
      visible: !_beenTapped,
      child: BounceAnimation(
        controller: _controller,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          child: Container(
            width: 150,
            height: 375,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
            child: _stack,
          ),
        ),
      ),
    );
  }
}
