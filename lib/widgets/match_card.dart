import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/animations/bounce_animation.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'package:rendezvous_beta_v3/widgets/tile_card.dart';
import 'package:intl/intl.dart';

import '../services/match_data_service.dart';

class MatchCard extends StatefulWidget {
  // TODO: figure out how to check if they have unread messages
  const MatchCard({Key? key, required this.data}) : super(key: key);
  final Future<MatchCardData> data;

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late bool _beenTapped;
  late MatchCardData _data;

  Widget get _circleAvatar => Align(
        alignment: const Alignment(.75, 0.25),
        child: CircleAvatar(
          backgroundImage: _data.image == null
              ? null
              : NetworkImage(_data.image!),
          radius: 45,
        ),
      );


  Widget get UI {
    // TODO: beautify the standard layout
    if (_data.dateTime == null) {
      // standard layout
      return Stack(
        children: <Widget>[
          MatchName(name: _data.name, dateType: _data.dateType),
          const DateOptionsBar(hasUnreadMessages: false),
          _circleAvatar,
          MatchCardOverlay(activeDate: _beenTapped)
        ],
      );
    } else {
      // date layout
      return Stack(
        children: <Widget>[
          const DateOptionsBar(hasUnreadMessages: false),
          _circleAvatar,
          MatchName(name: _data.name, dateType: _data.dateType),
          DateInfo(
              venue: _data.venue!, dateTime: _data.dateTime!),
        ],
      );
    }
  }

  @override
  void initState() async {
    _data = await widget.data;
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _beenTapped = false;
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
        onTapDown: (details) {
          if (_data.dateTime == null) {
            _controller.forward();
          }
        },
        onTapUp: (details) {
          setState(() => _beenTapped = true);
          if (_data.dateTime == null) {
            _controller.reverse();
          }
        },
        child: SizedBox(
          height: 175,
          child: TileCard(
            padding: const EdgeInsets.all(0),
            child: UI,
          ),
        ),
      ),
    );
  }
}


class MatchName extends StatelessWidget {
  const MatchName({Key? key, required this.name, this.dateType})
      : super(key: key);
  final String name;
  final String? dateType;

  Widget get _name {
    String? displayedName;
    if (dateType != null) {
      displayedName = "$dateType Date with $name";
    }
    return Text(displayedName ?? name, style: kTextStyle);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(-0.85, -.9),
        child: FittedBox(child: _name, fit: BoxFit.scaleDown),
    );
  }
}

class DateInfo extends StatelessWidget {
  DateInfo({Key? key, required this.venue, required this.dateTime})
      : super(key: key);
  final String venue;
  final DateTime dateTime;
  final DateFormat formatter = DateFormat('EEEE, d MMMM, h:mm a');

  String? get displayDate {
    return formatter.format(DateTime.parse(dateTime.toString()));
  }

  Widget get _dateDescription {
    return Align(
      alignment: const Alignment(-0.85, -0.2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        textBaseline: TextBaseline.ideographic,
        children: <Widget>[
          Text("at $venue"),
          const SizedBox(height: 10),
          Text("on $displayDate")
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _dateDescription;
  }
}

class DateOptionsBar extends StatelessWidget {
  const DateOptionsBar({Key? key, required this.hasUnreadMessages}) : super(key: key);
  final bool hasUnreadMessages;

  void _onMessageTap() {}

  void _onDetailsTap() {}

  Widget get _messageButton {
    return GestureDetector(
      onTap: _onMessageTap,
      child: Stack(
          children: [
            const Icon(Icons.message, color: Colors.white),
            Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasUnreadMessages ? Colors.red : Colors.transparent
              ),
            )
          ],
        ),
    );
  }

  Widget get _detailsButton => IconButton(
    onPressed: _onDetailsTap,
    icon: Icon(
      Platform.isIOS ? Icons.more_horiz : Icons.more_vert,
      color: Colors.white,
      size: 25,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _messageButton,
          _detailsButton
        ],
      ),
    );
  }
}

class MatchCardOverlay extends StatelessWidget {
  const MatchCardOverlay({Key? key, required this.activeDate}) : super(key: key);
  final bool activeDate;

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: const Alignment(-0.85, 0.6),
        decoration: BoxDecoration(
            color: !activeDate
                ? kDarkTransparent.withOpacity(0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(25)),
        child: !activeDate
            ? Text(
          "Tap to ask out",
          style: kTextStyle.copyWith(
              color: Colors.redAccent, fontSize: 20),
        )
            : null);
  }
}

