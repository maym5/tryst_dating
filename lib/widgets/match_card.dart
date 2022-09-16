import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'package:rendezvous_beta_v3/models/dates_model.dart';
import 'package:rendezvous_beta_v3/services/authentication_service.dart';
import 'package:rendezvous_beta_v3/services/messaging_service.dart';
import 'package:rendezvous_beta_v3/widgets/chat_view/chat_view.dart';
import 'package:rendezvous_beta_v3/widgets/fields/photo_picker.dart';
import 'package:rendezvous_beta_v3/widgets/tile_card.dart';
import 'package:intl/intl.dart';
import '../animations/bounce_animation.dart';
import '../services/match_data_service.dart';

class DateCard extends StatefulWidget {
  const DateCard({Key? key, required this.data}) : super(key: key);
  final DateData data;

  @override
  State<DateCard> createState() => _DateCardState();
}

class _DateCardState extends State<DateCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late bool _canTap;

  Widget get _circleAvatar => Align(
        alignment: const Alignment(.75, 0.25),
        child: CircleAvatar(
          backgroundImage: widget.data.image == null
              ? null
              : NetworkImage(widget.data.image!),
          radius: 40,
        ),
      );

  Widget get _tapText => Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Text(
            "Tap to ask out!",
            style: kTextStyle.copyWith(color: Colors.redAccent, fontSize: 18),
          ),
        ),
      );

  bool get _thereIsADate => widget.data.venue != null &&  widget.data.dateTime != null && widget.data.dateType != null;

  Widget get ui {
    return Stack(
      children: <Widget>[
        NameAndButtons(data: widget.data),
        Row(
          children: [
            _thereIsADate ? Expanded(
              flex: 2,
              child: DateInfo(
                venue: widget.data.venue!,
                dateTime: widget.data.dateTime!,
                dateType: widget.data.dateType!,
              ),
            ): Container(),
            Expanded(child: _circleAvatar, flex: 1,)
          ],
        ),
        // _circleAvatar,
        // _thereIsADate ? DateInfo(
        //   venue: widget.data.venue!,
        //   dateTime: widget.data.dateTime!,
        //   dateType: widget.data.dateType!,
        // ): Container(),
        _canTap ? _tapText : Container()
      ],
    );
  }

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _canTap = widget.data.agreedToDate != null ? !widget.data.agreedToDate!
        .contains(AuthenticationService.currentUserUID) : false;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) async {
        if (_canTap) {
          _controller.forward();
          await MatchDataService.confirmDate(otherUserUID: widget.data.matchID);
        }
      },
      onTapUp: (TapUpDetails details) {
        if (_canTap) {
          _controller.reverse();
          setState(() => _canTap = false);
        }
      },
      child: BounceAnimation(
        controller: _controller,
        child: Opacity(
          opacity: widget.data.agreedToDate == null || widget.data.agreedToDate!.length == 2 ? 1 : 0.5,
          child: SizedBox(
            height: 175,
            child: TileCard(
              padding: const EdgeInsets.all(0),
              child: ui,
            ),
          ),
        ),
      ),
    );
  }
}

class MatchName extends StatelessWidget {
  const MatchName(
      {Key? key,
      required this.name,
      this.dateType})
      : super(key: key);
  final String name;
  final String? dateType;

  Widget get _name {
    return Text("Date with $name",
        style: kTextStyle, softWrap: true, textAlign: TextAlign.start);
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
        child: _name, fit: BoxFit.scaleDown, alignment: Alignment.centerLeft);
  }
}

class DateInfo extends StatelessWidget {
  DateInfo(
      {Key? key,
      required this.venue,
      required this.dateTime,
      required this.dateType})
      : super(key: key);
  final String venue;
  final String dateType;
  final DateTime dateTime;
  final DateFormat formatter = DateFormat('EEEE, d MMMM, h:mm a');

  String? get displayDate =>
      formatter.format(DateTime.parse(dateTime.toString()));

  String get _dateType {
    String dateTypeString = "";
    int index = 0;
    for (String char in dateType.characters) {
      if (char == char.toUpperCase() || index == 0) {
        dateTypeString += (" " + char.toUpperCase());
      } else {
        char.toLowerCase();
        dateTypeString += char;
      }
      index++;
    }
    return dateTypeString + " date";
  }

  Widget get _dateDescription => FittedBox(
    fit: BoxFit.scaleDown,
    child: Padding(
      padding: const EdgeInsets.only(left: 10, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        textBaseline: TextBaseline.ideographic,
        children: <Widget>[
          Row(
            children: [
              const Icon(Icons.where_to_vote,
                  color: Colors.white, size: 18),
              const SizedBox(
                width: 5,
              ),
              Text(_dateType)
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_business_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 5),
              Text(venue, softWrap: true,),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer, color: Colors.white, size: 18),
              const SizedBox(width: 5),
              Text(displayDate!, softWrap: true),
            ],
          )
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return _dateDescription;
  }
}

class DateOptionsBar extends StatefulWidget {
  const DateOptionsBar({Key? key, required this.data}) : super(key: key);
  final DateData data;

  @override
  State<DateOptionsBar> createState() => _DateOptionsBarState();
}

class _DateOptionsBarState extends State<DateOptionsBar> {
  late Stream<QuerySnapshot> unreadMessages =
      MessengingService().unreadMessages(widget.data.matchID);

  void _onMessageTap() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatView(
              image: widget.data.image!,
              name: widget.data.name,
              match: widget.data.matchID),
        ));
  }

  void _onDetailsTap() {
    showModalBottomSheet(
        context: context,
        builder: (context) =>
            DetailsBottomSheet(data: widget.data));
  }

  Widget get _messageButton => GestureDetector(
        onTap: _onMessageTap,
        child: Stack(
          children: [
            const Icon(Icons.message, color: Colors.white),
            StreamBuilder(
              stream: unreadMessages,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) =>
                  snapshot.hasData && snapshot.data!.size != 0
                      ? Container(
                          height: 10,
                          width: 10,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.red),
                        )
                      : Container(
                          height: 10,
                          width: 10,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.transparent),
                        ),
            )
          ],
        ),
      );

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
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[_messageButton, _detailsButton],
      ),
    );
  }
}

class DateTypeIcon extends StatelessWidget {
  const DateTypeIcon({Key? key, required this.icon}) : super(key: key);
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration:
          const BoxDecoration(shape: BoxShape.circle, color: Colors.black45),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class MatchDateType extends StatelessWidget {
  MatchDateType({Key? key, required this.dateTypes}) : super(key: key);
  final List dateTypes;
  final Map<String, IconData> _icons = {
    "restaurant": Icons.restaurant,
    "cafe": Icons.local_cafe_sharp,
    "museum": Icons.museum_rounded,
    "bowlingAlley": Icons.album_rounded,
    "bar": Icons.local_bar,
    "bakery": Icons.bakery_dining,
    "nightClub": Icons.music_note_outlined,
    "artGallery": Icons.brush,
    "park": Icons.park
  };

  List<DateTypeIcon> get children {
    List<DateTypeIcon> result = [];
    int index = 0;
    for (var dateType in dateTypes) {
      if (index <= 6) {
        result.add(DateTypeIcon(icon: _icons[dateType]!));
      }
      index++;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(-0.85, -0.25),
      child: Wrap(
        runSpacing: 10.0,
        children: children,
      ),
    );
  }
}

class NameAndButtons extends StatelessWidget {
  const NameAndButtons({Key? key, required this.data}) : super(key: key);
  final DateData data;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 10,
          ),
          Flexible(
              child: MatchName(
                name: data.name,
                dateType: data.dateType,
              ),
              flex: 4,
              fit: FlexFit.tight),
          const SizedBox(
            width: 10,
          ),
          Flexible(
            child: DateOptionsBar(data: data),
            flex: 1,
          )
        ],
      ),
    );
  }
}

class DetailsBottomSheet extends StatelessWidget {
  const DetailsBottomSheet({Key? key, required this.data})
      : super(key: key);
  final DateData data;

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      tileColor: kPopUpColor,
        iconOne: Icons.delete,
        iconTwo: Icons.calendar_today,
        titleOne: "Delete this date",
        titleTwo: "Reschedule this date",
        onTileOneTap: () async {
          await DatesModel(dateData: data).deleteData(context);
        },
        onTileTwoTap: () async {
          if (data.venueID != null) {
            await DatesModel(dateData: data).rescheduleDate(context);
          } else {
            // print("venueID null");
          }
        });
  }
}
