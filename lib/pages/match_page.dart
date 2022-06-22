import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/services/match_data_service.dart';
import 'package:rendezvous_beta_v3/widgets/match_card.dart';
import 'package:rendezvous_beta_v3/widgets/match_tile.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';

import '../services/authentication.dart';

class MatchPage extends StatefulWidget {
  const MatchPage({Key? key}) : super(key: key);
  static const id = "match_page";

  @override
  State<MatchPage> createState() => _MatchPageState();

  // Widget get _name {
  //   String displayedText = "Date with $name!";
  //   return Text(displayedText,
  //       style: kTextStyle, softWrap: true, textAlign: TextAlign.start);
  // }
}

class _MatchPageState extends State<MatchPage> {
  @override
  Widget build(BuildContext context) {
    return PageBackground(
        body: SafeArea(
      child: StreamBuilder(
        stream: MatchDataService().datesData,
        builder: (BuildContext context,
            AsyncSnapshot<List<MatchCardData>?> dateSnapshot) {
          return StreamBuilder(
              stream: MatchDataService().matchData,
              builder: (BuildContext context,
                  AsyncSnapshot<List<MatchCardData>?> matchSnapshot) {
                if (dateSnapshot.hasData &&
                    matchSnapshot.hasData &&
                    !dateSnapshot.hasError &&
                    !matchSnapshot.hasError) {
                  print(dateSnapshot.data!.length);
                  print(matchSnapshot.data!.length);
                  return ListView.builder(
                      itemCount: dateSnapshot.data!.length +
                          matchSnapshot.data!.length,
                      itemBuilder: (context, index) {
                        if (index < dateSnapshot.data!.length) {
                          return MatchCard(data: dateSnapshot.data![index]);
                        } else {
                          return MatchCard(
                              data: matchSnapshot
                                  .data![index - dateSnapshot.data!.length]);
                        }
                      });
                } else if (dateSnapshot.hasData) {
                  return ListView.builder(
                      itemCount: dateSnapshot.data!.length,
                      itemBuilder: (context, index) =>
                          MatchCard(data: dateSnapshot.data![index]));
                } else if (matchSnapshot.hasData) {
                  return ListView.builder(
                      itemCount: matchSnapshot.data!.length,
                      itemBuilder: (context, index) =>
                          MatchCard(data: matchSnapshot.data![index]));
                } else if (!dateSnapshot.hasData && !matchSnapshot.hasData) {
                  return Container(
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height,
                    child: const Text("Such empty, get swiping!"),
                  );
                } else {
                  return Container(
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height,
                    child: const Text(
                        "There's been an error loading your match data, try again soon"),
                  );
                }
              });
        },
      ),
    ));
  }
}

class DatesPage extends StatelessWidget {
  const DatesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: StreamBuilder(
        stream: MatchDataService().datesData,
          builder: (BuildContext context, AsyncSnapshot<List<MatchCardData>?> dateSnapshot) {
          if (dateSnapshot.hasData && !dateSnapshot.hasError) {
            return ListView.builder(
              itemCount: dateSnapshot.data!.length,
                itemBuilder: (context, index) => MatchCard(data: dateSnapshot.data![index])
            );
          } else if (!dateSnapshot.hasData) {
            return Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height,
              child: const Text("Such empty, get swiping!"),
            );
          } else {
            return Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height,
              child: const Text(
                  "There's been an error loading your match data, try again soon"),
            );
          }
        }
      ),
    );
  }
}

class LikesPage extends StatefulWidget {
  const LikesPage({Key? key}) : super(key: key);

  @override
  State<LikesPage> createState() => _LikesPageState();
}

class _LikesPageState extends State<LikesPage> {

  late Stream<List<MatchCardData>?> matchData;

  @override
  void initState() {
    matchData = MatchDataService().matchData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: StreamBuilder(
          stream: matchData,
          builder: (BuildContext context, AsyncSnapshot<List<MatchCardData>?> likeSnapshot) {
            if (likeSnapshot.hasData && !likeSnapshot.hasError) {
              return GridView.builder(
                itemCount: likeSnapshot.data!.length,
                itemBuilder: (BuildContext context, int index) => MatchTile(data: likeSnapshot.data![index]),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0
                ),
              );
            } else if (!likeSnapshot.hasData) {
              return Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height,
                child: const Text("Don't worry, people are liking you right now!"),
              );
            }
            else {
              return Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height,
                child: const Text(
                    "There's been an error loading your match data, try again soon"),
              );
            }
          }
      ),
    );
  }
}



class MatchPageTwo extends StatefulWidget {
  const MatchPageTwo({Key? key}) : super(key: key);
  static const id = "match_page_two";

  @override
  State<MatchPageTwo> createState() => _MatchPageTwoState();
}

class _MatchPageTwoState extends State<MatchPageTwo> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  Widget get _dates => const DatesPage();

  Widget get _likes => const LikesPage();

  List<Widget> get _children => [_dates, _likes];

  static const List<Tab> _tabs = <Tab>[
    Tab(text: "Dates",),
    Tab(text: "Likes",)
  ];

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          indicatorColor: Colors.redAccent,
        ),
      ),
        body: TabBarView(
          controller: _tabController,
            children: _children,
        ),
    );
  }
}


// return ListView.builder(
// itemCount: _data.length,
// itemBuilder: (context, index) {
// return MatchCard(data: _data[index]);
// });

//
// (context, index) =>
// snapshot.data![index] != null
// ? MatchCard(data: snapshot.data![index]!)
// : Container());

// class MatchPageTwo extends StatefulWidget {
//   const MatchPageTwo({Key? key}) : super(key: key);
//
//   @override
//   State<MatchPageTwo> createState() => _MatchPageTwoState();
// }
//
// class _MatchPageTwoState extends State<MatchPageTwo> {
//   final List<MatchCard> matchCardChildren = [];
//
//
//   @override
//   Widget build(BuildContext context) {
//     return PageBackground(
//         body: StreamBuilder(
//           stream: MatchDataService().newDatesData,
//           builder: (context, AsyncSnapshot<MatchCardData> snapshot) {
//             if (snapshot.hasData && !snapshot.hasError && snapshot.data != null) {
//               matchCardChildren.add(MatchCard(data: snapshot.data!));
//               return ListView(
//                 children: matchCardChildren,
//               );
//             } else if (!snapshot.hasData || snapshot.data == null) {
//               return Container(
//                 alignment: Alignment.center,
//                 height: MediaQuery.of(context).size.height,
//                 child: const Text("Such empty, get swiping!"),
//               );
//             } else {
//               return Container(
//                 alignment: Alignment.center,
//                 height: MediaQuery.of(context).size.height,
//                 child: const Text(
//                     "There's been an error loading your match data, try again soon"),
//               );
//             }
//           },
//         )
//     );
//   }
// }
