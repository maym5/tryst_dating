import 'dart:io';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:rendezvous_beta_v3/animations/bounce_animation.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'package:rendezvous_beta_v3/widgets/tile_card.dart';
import 'package:intl/intl.dart';

class MatchCard extends StatefulWidget {
  // TODO: more construction doing too much here
  const MatchCard({Key? key, required this.data}) : super(key: key);
  final MatchCardData data;

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late bool _beenTapped;

  Widget get _circleAvatar => Align(
        alignment: const Alignment(.75, 0.25),
        child: CircleAvatar(
          backgroundImage: widget.data.image == null
              ? null
              : NetworkImage(widget.data.image!),
          radius: 45,
        ),
      );

  Widget get UI {
    if (widget.data.dateTime == null) {
      // standard layout
      return Stack(
        children: <Widget>[
          Align(
            child: MatchName(
                name: widget.data.name, dateType: widget.data.dateType),
            alignment: const Alignment(-.9, -0.75),
          ),
          const DateOptionsBar(hasUnreadMessages: true),
          _circleAvatar,
          MatchCardOverlay(activeDate: _beenTapped)
        ],
      );
    } else {
      // data layout
      return Stack(
        children: <Widget>[
          const DateOptionsBar(hasUnreadMessages: false),
          _circleAvatar,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MatchName(name: widget.data.name, dateType: widget.data.dateType),
              DateInfo(
                  venue: widget.data.venue!, dateTime: widget.data.dateTime!),
            ],
          ),
          // Container(color: _beenTapped ? Colors.grey : Colors.transparent)
        ],
      );
    }
  }

  @override
  void initState() {
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
          if (widget.data.dateTime == null) {
            _controller.forward();
          }
        },
        onTapUp: (details) {
          setState(() => _beenTapped = true);
          if (widget.data.dateTime == null) {
            _controller.reverse();
          }
        },
        child: SizedBox(
          height: 185,
          child: TileCard(
            padding: const EdgeInsets.all(0),
            child: UI,
          ),
        ),
      ),
    );
  }
}

class MatchCardData {
  // gonna need a factory
  MatchCardData({
    required this.name,
    this.image,
    this.dateTime,
    this.venue,
    this.dateType,
  });
  final String name;
  final String? image;
  final String? venue;
  final DateTime? dateTime;
  final String? dateType;
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
    return Text(displayedName ?? name,
        style: kTextStyle.copyWith(fontSize: 35));
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(child: _name);
  }
}

class DateInfo extends StatelessWidget {
  DateInfo({Key? key, required this.venue, required this.dateTime})
      : super(key: key);
  final String venue;
  final DateTime dateTime;
  final DateFormat formatter = DateFormat('EEEE, dd MMMM, h:mm');

  String? get displayDate {
    return formatter.format(DateTime.parse(dateTime.toString()));
  }

  Widget get _dateDescription {
    return Align(
      alignment: const Alignment(-0.9, -0.5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
  const DateOptionsBar({Key? key, required this.hasUnreadMessages})
      : super(key: key);
  final bool hasUnreadMessages;

  void _onMessageTap() {}

  void _onDetailsTap() {}

  Widget get _messageButton {
    return GestureDetector(
      onTap: _onMessageTap,
      child: Stack(
        children: [
          const Icon(Icons.message, color: Colors.white),
          hasUnreadMessages
              ? Container(
                  height: 10,
                  width: 10,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.red),
                )
              : Container()
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
        children: <Widget>[_messageButton, _detailsButton],
      ),
    );
  }
}

class MatchCardOverlay extends StatelessWidget {
  const MatchCardOverlay({Key? key, required this.activeDate})
      : super(key: key);
  final bool activeDate;

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: const Alignment(-0.9, 0.5),
        decoration: BoxDecoration(
            color: !activeDate
                ? kDarkTransparent.withOpacity(0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(25)),
        child: !activeDate
            ? Text(
                "Tap to ask out",
                style:
                    kTextStyle.copyWith(color: Colors.redAccent, fontSize: 20),
              )
            : null);
  }
}
