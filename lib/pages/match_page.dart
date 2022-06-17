import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/services/match_data_service.dart';
import 'package:rendezvous_beta_v3/widgets/match_card.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';

// class MatchPage extends StatefulWidget {
//   static const id = "match_page";
//   const MatchPage({Key? key}) : super(key: key);
//
//   @override
//   State<MatchPage> createState() => _MatchPageState();
// }
//
// class _MatchPageState extends State<MatchPage> {
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return PageBackground(
//       body: SafeArea(
//         child: StreamBuilder(
//             stream: MatchDataService().matchDataStream,
//             builder: (BuildContext context,
//                 AsyncSnapshot<List<MatchCardData?>> snapshot) {
//               if (snapshot.hasData && !snapshot.hasError) {
//                 // print(snapshot.data!.length);
//                 return ListView.builder(
//                     itemCount: snapshot.data!.length,
//                     itemBuilder: (context, index) {
//                       return MatchCard(data: snapshot.data![index]!);
//                     });
//               } else if (!snapshot.hasData) {
//                 return Container(
//                   alignment: Alignment.center,
//                   height: MediaQuery.of(context).size.height,
//                   child: const Text("Such empty, get swiping!"),
//                 );
//               } else {
//                 return Container(
//                   alignment: Alignment.center,
//                   height: MediaQuery.of(context).size.height,
//                   child: const Text(
//                       "There's been an error loading your match data, try again soon"),
//                 );
//               }
//             }),
//       ),
//     );
//   }
// }

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
                  // print(dateSnapshot.data!.length);
                  // print(matchSnapshot.data!.length);
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
