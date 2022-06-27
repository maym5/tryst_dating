import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/services/match_data_service.dart';
import 'package:rendezvous_beta_v3/widgets/match_card.dart';
import 'package:rendezvous_beta_v3/widgets/match_tile.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';


// class MatchPage extends StatefulWidget {
//   const MatchPage({Key? key}) : super(key: key);
//   static const id = "match_page";
//
//   @override
//   State<MatchPage> createState() => _MatchPageState();
//
//   // Widget get _name {
//   //   String displayedText = "Date with $name!";
//   //   return Text(displayedText,
//   //       style: kTextStyle, softWrap: true, textAlign: TextAlign.start);
//   // }
// }
//
// class _MatchPageState extends State<MatchPage> {
//   @override
//   Widget build(BuildContext context) {
//     return PageBackground(
//         body: SafeArea(
//       child: StreamBuilder(
//         stream: MatchDataService().datesData,
//         builder: (BuildContext context,
//             AsyncSnapshot<List<MatchCardData>?> dateSnapshot) {
//           return StreamBuilder(
//               stream: MatchDataService().matchData,
//               builder: (BuildContext context,
//                   AsyncSnapshot<List<MatchCardData>?> matchSnapshot) {
//                 if (dateSnapshot.hasData &&
//                     matchSnapshot.hasData &&
//                     !dateSnapshot.hasError &&
//                     !matchSnapshot.hasError) {
//                   print(dateSnapshot.data!.length);
//                   print(matchSnapshot.data!.length);
//                   return ListView.builder(
//                       itemCount: dateSnapshot.data!.length +
//                           matchSnapshot.data!.length,
//                       itemBuilder: (context, index) {
//                         if (index < dateSnapshot.data!.length) {
//                           return MatchCard(data: dateSnapshot.data![index]);
//                         } else {
//                           return MatchCard(
//                               data: matchSnapshot
//                                   .data![index - dateSnapshot.data!.length]);
//                         }
//                       });
//                 } else if (dateSnapshot.hasData) {
//                   return ListView.builder(
//                       itemCount: dateSnapshot.data!.length,
//                       itemBuilder: (context, index) =>
//                           MatchCard(data: dateSnapshot.data![index]));
//                 } else if (matchSnapshot.hasData) {
//                   return ListView.builder(
//                       itemCount: matchSnapshot.data!.length,
//                       itemBuilder: (context, index) =>
//                           MatchCard(data: matchSnapshot.data![index]));
//                 } else if (!dateSnapshot.hasData && !matchSnapshot.hasData) {
//                   return Container(
//                     alignment: Alignment.center,
//                     height: MediaQuery.of(context).size.height,
//                     child: const Text("Such empty, get swiping!"),
//                   );
//                 } else {
//                   return Container(
//                     alignment: Alignment.center,
//                     height: MediaQuery.of(context).size.height,
//                     child: const Text(
//                         "There's been an error loading your match data, try again soon"),
//                   );
//                 }
//               });
//         },
//       ),
//     ));
//   }
// }

class DatesPage extends StatefulWidget {
  const DatesPage({Key? key}) : super(key: key);

  @override
  State<DatesPage> createState() => _DatesPageState();
}

class _DatesPageState extends State<DatesPage> {
  final Stream<List<MatchData>?> _datesStream = MatchDataService().datesStream;

  Widget get _emptyMessage => Container(
    alignment: Alignment.center,
    height: MediaQuery.of(context).size.height,
    child: const Text("Such empty, get swiping!"),
  );

  Widget get _errorMessage => Container(
    alignment: Alignment.center,
    height: MediaQuery.of(context).size.height,
    child: const Text(
        "There's been an error loading your dates data, try again soon"),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: StreamBuilder(
        stream: _datesStream,
          builder: (BuildContext context, AsyncSnapshot<List<MatchData>?> dateSnapshot) {
          if (dateSnapshot.hasData && !dateSnapshot.hasError) {
            return ListView.builder(
              itemCount: dateSnapshot.data!.length,
                itemBuilder: (context, index) => DateCard(data: dateSnapshot.data![index])
            );
          } else if (!dateSnapshot.hasData) {
            return _emptyMessage;
          } else {
            return _errorMessage;
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
  final Stream<List<MatchData>?> _likesStream = MatchDataService().likesStream;

  Widget get _noLikesMessage => Container(
    alignment: Alignment.center,
    height: MediaQuery.of(context).size.height,
    child: const Text("Don't worry, people are liking you right now!"),
  );

  Widget get _errorMessage => Container(
    alignment: Alignment.center,
    height: MediaQuery.of(context).size.height,
    child: const Text(
        "There's been an error loading your match data, try again soon"),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: StreamBuilder<List<MatchData>?>(
          stream: _likesStream,
          builder: (BuildContext context, AsyncSnapshot<List<MatchData>?> likeSnapshot) {
            if (likeSnapshot.hasData && !likeSnapshot.hasError) {
              // TODO: make this a reorderable gridview
              return GridView.builder(
                itemCount: likeSnapshot.data!.length,
                itemBuilder: (BuildContext context, int index) => MatchTile(data: likeSnapshot.data![index]),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 0.8,
                    crossAxisCount: 2,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 8.0
                ),
              );
            } else if (!likeSnapshot.hasData) {
              return _noLikesMessage;
            }
            else {
              return _errorMessage;
            }
          }
      ),
    );
  }
}



class MatchPage extends StatefulWidget {
  const MatchPage({Key? key}) : super(key: key);
  static const id = "match_page";

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> with SingleTickerProviderStateMixin {
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
