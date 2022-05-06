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
  final DateFormat formatter = DateFormat('EEEE, dd MMMM, h:mm');

  String? get displayDate {
    if (widget.data.dateTime != null) {
      return formatter.format(DateTime.parse(widget.data.dateTime.toString()));
    }
    return null;
  }

  Widget get _circleAvatar => Align(
        alignment: const Alignment(.75, 0.25),
        child: CircleAvatar(
          backgroundImage: widget.data.image == null
              ? null
              : NetworkImage(widget.data.image!),
          radius: 45,
        ),
      );

  Widget get _name {
    String nameString;
    if (widget.data.dateType != null) {
      nameString = widget.data.dateType! + "Date with" + widget.data.name;
    } else {
      nameString = widget.data.name;
    }
    return Text(nameString, style: kTextStyle);
  }

  Widget? get _venue => Text("at ${widget.data.venue}");

  Widget get _dateTimeHeader => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(displayDate ?? "", style: kTextStyle),
        ],
      );

  Widget get _optionsBar => Align(
        alignment: Alignment.topRight,
        child: IconButton(
          onPressed: () {
            // _showBottomSheet(context);
          },
          icon: Icon(
            Platform.isIOS ? Icons.more_horiz : Icons.more_vert,
            color: Colors.white,
            size: 25,
          ),
        ),
      );

  // Widget get centerIcon => widget.data.rating >= 5
  //     ? const Icon(
  //   Icons.favorite,
  //   color: Colors.redAccent,
  //   size: 50.0,
  // )
  //     : const Icon(
  //   Icons.clear,
  //   color: Colors.orange,
  //   size: 50.0,
  // );
  //
  // Widget get centerTitle => const Padding(
  //   padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
  //   child: Text(
  //     'Your Rating:',
  //     style: TextStyle(
  //       color: Colors.white,
  //       fontFamily: 'Raleway',
  //       fontWeight: FontWeight.w400,
  //       fontSize: 18,
  //     ),
  //   ),
  // );
  //
  // Widget get centerText => Text(
  //   widget.data.rating.toStringAsFixed(1),
  //   style: const TextStyle(
  //     color: Colors.white,
  //     fontFamily: 'Raleway', // get techno font here
  //     fontWeight: FontWeight.bold,
  //     fontSize: 20,
  //   ),
  // );
  //
  // Widget get _rating => CircularPercentIndicator(
  //   circularStrokeCap: CircularStrokeCap.butt,
  //   radius: 50,
  //   percent: widget.data.rating / 10,
  //   progressColor:
  //   widget.data.rating >= 5 ? Colors.green : Colors.redAccent,
  //   lineWidth: 10.0,
  //   reverse: true,
  //   backgroundColor: Colors.transparent,
  //   center: Column(
  //     children: [
  //       centerTitle,
  //       centerText,
  //       centerIcon
  //     ],
  //   ),
  // );

  Widget get UI {
    if (widget.data.dateTime == null) {
      // standard layout
      return Stack(
        children: <Widget>[
          Align(
            alignment: const Alignment(-0.9, -0.5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _name,
                const SizedBox(width: 10),
              ],
            ),
          ),
          _optionsBar,
          _circleAvatar,
          Container(
              alignment: const Alignment(-0.9, 0.5),
              decoration: BoxDecoration(
                  color: !_beenTapped
                      ? kDarkTransparent.withOpacity(0.3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(25)),
              child: !_beenTapped
                  ? Text(
                      "Tap to ask out",
                      style: kTextStyle.copyWith(
                          color: Colors.redAccent, fontSize: 20),
                    )
                  : null),
        ],
      );
    } else {
      // data layout
      return Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _dateTimeHeader,
              _optionsBar,
              Row(
                children: [_name, _venue!],
              ),
              _circleAvatar
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
