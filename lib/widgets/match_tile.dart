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
  final MatchData data;

  @override
  State<MatchTile> createState() => _MatchTileState();
}

class _MatchTileState extends State<MatchTile> with TickerProviderStateMixin {
  DateTime? _dateTime;
  late final AnimationController _controller;

  void _setDateTime(DateTime date, TimeOfDay time) {
    setState(() {
      _dateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _controller.forward());
  }

  void _onTapUp(TapUpDetails details) async {
    setState(() => _controller.reverse());
    List? _commonDates = widget.data.dateTypes
        ?.where((element) => UserData.dates.contains(element))
        .toList();
    if (_commonDates != null) {
      final _dateType = _commonDates[Random().nextInt(_commonDates.length)];
      final Map _venue = await GooglePlacesService(venueType: _dateType).venue;
      if (_venue["status"] == "OK") {
        await DateTimeDialogue(setDateTime: _setDateTime).buildCalendarDialogue(
            context,
            venueName: _venue["name"],
            matchName: widget.data.name);
        final _isOpen =
            await GooglePlacesService.checkDateTime(_dateTime!, _venue);
        if (_dateTime != null && _isOpen) {
          await MatchDataService.updateMatchData(
              otherUserUID: widget.data.matchID,
              dateType: _dateType,
              dateTime: _dateTime!,
              venue: _venue["name"]);
        } else if (!_isOpen) {
          // do a pop up
          await DateTimeDialogue(setDateTime: _setDateTime)
              .buildCalendarDialogue(context,
                  venueName: _venue["name"],
                  matchName: widget.data.name,
                  pickAnother: true);
        } else {
          // do a pop up
          print("dateTime is null");
        }
      }
    } else {
      print("I have no common dates master");
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
    return BounceAnimation(
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
    );
  }
}
