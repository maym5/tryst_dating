import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'package:rendezvous_beta_v3/services/match_data_service.dart';
import 'package:rendezvous_beta_v3/widgets/date_card.dart';
import 'package:rendezvous_beta_v3/widgets/match_tile.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';

class LikesPage extends StatefulWidget {
  const LikesPage({Key? key}) : super(key: key);

  @override
  State<LikesPage> createState() => _LikesPageState();
}

class _LikesPageState extends State<LikesPage> {
  late final Stream<List<DocumentSnapshot>> _likesStream;

  Widget get _noLikesMessage => Padding(
        padding: const EdgeInsets.only(top: 25),
        child: Column(children: [
          Image.asset("assets/images/love.png", height: 250),
          const SizedBox(
            height: 50,
          ),
          Text(
            "Don't worry, people are liking you right now!",
            style: kTextStyle.copyWith(fontSize: 24),
            softWrap: true,
            textAlign: TextAlign.center,
          ),
        ]),
      );



  Widget get _errorMessage => Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        child: Text(
          "There's been an error loading your match data, try again soon",
          style: kTextStyle.copyWith(fontSize: 24),
        ),
      );

  Widget get _noInternet => Container(
        alignment: Alignment.center,
        child: Text(
          "You don't have any internet connection",
          style: kTextStyle,
          textAlign: TextAlign.center,
        ),
      );

  Widget get _loading => const Center(
        child: SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(color: Colors.redAccent),
        ),
      );

  Widget _likeBuilder(
      BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> likeSnapshot) {
    if (likeSnapshot.hasData &&
        !likeSnapshot.hasError) {
      final List<DateData> matchData = [];
      for (DocumentSnapshot doc in likeSnapshot.data!) {
        if (doc.exists && doc.data() != null) {
          final Map _data = doc.data() as Map;
          matchData.add(DateData(
              name: _data["name"],
              matchID: _data["matchUID"],
              image: _data["avatarImage"],
              age: _data["age"],
              dateTypes: _data["dateTypes"]));
        }
      }
      return GridView.builder(
        itemCount: matchData.length,
        itemBuilder: (BuildContext context, int index) =>
            MatchTile(data: matchData[index]),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 0.8,
            crossAxisCount: 2,
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 8.0),
      );
    } else if (!likeSnapshot.hasData || likeSnapshot.data!.isEmpty) {
      return _noLikesMessage;
    } else {
      return _errorMessage;
    }
  }

  @override
  void initState() {
    _likesStream = MatchDataService().likeStream;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: StreamBuilder<List<DocumentSnapshot>>(
          stream: _likesStream,
          builder: (BuildContext context,
              AsyncSnapshot<List<DocumentSnapshot>> likeSnapshot) {
            switch (likeSnapshot.connectionState) {
              case ConnectionState.none:
                return _noInternet;
              case ConnectionState.waiting:
                return _loading;
              case ConnectionState.active:
                return _likeBuilder(context, likeSnapshot);
              case ConnectionState.done:
                return _likeBuilder(context, likeSnapshot);
            }
          }),
    );
  }
}

class DatePage extends StatefulWidget {
  const DatePage({Key? key}) : super(key: key);

  @override
  State<DatePage> createState() => _DatePageState();
}

class _DatePageState extends State<DatePage> {
  final Stream<QuerySnapshot> _datesStream = MatchDataService().dateData;

  Widget get _emptyMessage => Column(
        children: [
          Image.asset("assets/images/such_empty.png"),
          const SizedBox(height: 15,),
          Text("Such empty, get rating!", style: kTextStyle),
        ]
      );

  Widget get _errorMessage => Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        child: const Text(
            "There's been an error loading your dates data, try again soon"),
      );

  Widget get _noInternet => Container(
        alignment: Alignment.center,
        child: Text(
          "You don't have any internet connection",
          style: kTextStyle,
          textAlign: TextAlign.center,
        ),
      );

  Widget get _loading => const Center(
        child: SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(
              color: Colors.redAccent, strokeWidth: 4),
        ),
      );

  Widget get _customDivider => Expanded(
          child: Divider(
        thickness: 1,
        color: kTextStyle.color,
        height: 10,
        indent: 10,
        endIndent: 10,
      ));

  Row _dividerBuilder(String text) => Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          _customDivider,
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Text(text,
                style: kTextStyle.copyWith(fontSize: 25),
                textAlign: TextAlign.center),
          ),
          _customDivider
        ],
      );

  Widget _dateBuilder(
      BuildContext context, AsyncSnapshot<QuerySnapshot> dateSnapshot) {
    if (dateSnapshot.hasData &&
        !dateSnapshot.hasError &&
        dateSnapshot.data!.size != 0) {
      final List<DateData> upcomingDates = [];
      final List<DateData> pastDates = [];
      final List<DateData> pendingDates = [];
      final List<DateData> noDateMatch = [];
      for (DocumentSnapshot doc in dateSnapshot.data!.docs) {
        if (doc.exists && doc.data() != null) {
          final Map _data = doc.data() as Map;
          final List _agreedToDate = _data["agreedToDate"];
          if (_data["dateTime"] == null) {
            noDateMatch.add(DateData(
                name: _data["name"],
                matchID: _data["matchUID"],
                image: _data["avatarImage"],
                agreedToDate: _data["agreedToDate"]));
          } else if (_agreedToDate.length != 2 &&
              MatchDataService.convertTimeStamp(_data["dateTime"])
                  .isAfter(DateTime.now())) {
            pendingDates.add(DateData(
                name: _data["name"],
                age: _data["age"],
                image: _data["avatarImage"],
                matchID: _data["matchUID"],
                venue: _data["venue"],
                venueID: _data["venueID"],
                dateType: _data["dateType"],
                dateTime: MatchDataService.convertTimeStamp(
                  _data["dateTime"],
                ),
                agreedToDate: _data["agreedToDate"]));
          } else if (MatchDataService.convertTimeStamp(_data["dateTime"])
              .isAfter(DateTime.now())) {
            upcomingDates.add(DateData(
                name: _data["name"],
                age: _data["age"],
                image: _data["avatarImage"],
                matchID: _data["matchUID"],
                venue: _data["venue"],
                dateType: _data["dateType"],
                venueID: _data["venueID"],
                dateTime: MatchDataService.convertTimeStamp(
                  _data["dateTime"],
                ),
                agreedToDate: _data["agreedToDate"]));
          } else if (MatchDataService.convertTimeStamp(_data["dateTime"])
                  .isBefore(DateTime.now().add(const Duration(seconds: 5))) &&
              _agreedToDate.length == 2) {
            pastDates.add(DateData(
                name: _data["name"],
                age: _data["age"],
                image: _data["avatarImage"],
                matchID: _data["matchUID"],
                venue: _data["venue"],
                dateType: _data["dateType"],
                venueID: _data["venueID"],
                dateTime: MatchDataService.convertTimeStamp(_data["dateTime"]),
                agreedToDate: _data["agreedToDate"]));
          } else {
            MatchDataService.deleteDate(otherUserUID: _data["matchUID"]);
          }
        }
      }
      return ListView.builder(
          itemCount: upcomingDates.length +
              pastDates.length +
              pendingDates.length +
              noDateMatch.length,
          itemBuilder: (context, index) {
            if (index < upcomingDates.length) {
              return DateCard(data: upcomingDates[index]);
            } else if (index == upcomingDates.length && pastDates.isNotEmpty) {
              return Column(
                children: [
                  _dividerBuilder("Past Dates"),
                  DateCard(data: pastDates[0])
                ],
              );
            } else if (index < upcomingDates.length + pastDates.length) {
              return DateCard(data: pastDates[index - upcomingDates.length]);
            } else if (index == upcomingDates.length + pastDates.length &&
                pendingDates.isNotEmpty) {
              return Column(
                children: [
                  _dividerBuilder("Pending Dates"),
                  DateCard(data: pendingDates[0]),
                ],
              );
            } else if (index <
                upcomingDates.length + pastDates.length + pendingDates.length) {
              return DateCard(
                  data: pendingDates[
                      index - (upcomingDates.length + pastDates.length)]);
            } else if (index ==
                    upcomingDates.length +
                        pastDates.length +
                        pendingDates.length &&
                noDateMatch.isNotEmpty) {
              return Column(
                children: [
                  _dividerBuilder("Venueless matches"),
                  DateCard(data: noDateMatch[0]),
                ],
              );
            } else {
              return DateCard(
                  data: noDateMatch[index -
                      (upcomingDates.length +
                          pastDates.length +
                          pendingDates.length)]);
            }
          });
    } else if (!dateSnapshot.hasData || dateSnapshot.data!.size == 0) {
      return _emptyMessage;
    } else {
      return _errorMessage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: StreamBuilder<QuerySnapshot>(
          stream: _datesStream,
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> dateSnapshot) {
            switch (dateSnapshot.connectionState) {
              case ConnectionState.done:
                return _dateBuilder(context, dateSnapshot);
              case ConnectionState.waiting:
                return _loading;
              case ConnectionState.none:
                return _noInternet;
              case ConnectionState.active:
                return _dateBuilder(context, dateSnapshot);
            }
          }),
    );
  }
}

class MatchPage extends StatefulWidget {
  const MatchPage({Key? key}) : super(key: key);
  static const id = "match_page";

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  Widget get _dates => const DatePage();

  Widget get _likes => const LikesPage();

  List<Widget> get _children => [_dates, _likes];

  static const List<Tab> _tabs = <Tab>[
    Tab(
      text: "Dates",
    ),
    Tab(
      text: "Likes",
    )
  ];

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      decoration: kWelcomePageDecoration,
      appBar: AppBar(
        backgroundColor: Colors.black45,
        leading: const BackButton(color: Colors.transparent),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          indicatorColor: Colors.redAccent,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: _children,
      ),
    );
  }
}
