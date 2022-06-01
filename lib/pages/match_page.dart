import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/services/match_data_service.dart';
import 'package:rendezvous_beta_v3/widgets/match_card.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';

class MatchPage extends StatefulWidget {
  static const id = "match_page";
  const MatchPage({Key? key}) : super(key: key);

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      body: SafeArea(
        child: StreamBuilder(
            stream: MatchDataService().newFinalData,
            builder: (BuildContext context,
                AsyncSnapshot<List<MatchCardData?>> snapshot) {
              if (snapshot.hasData &&
                  !snapshot.hasError &&
                  snapshot.data!.isNotEmpty) {
                return ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) =>
                        snapshot.data![index] != null
                            ? MatchCard(data: snapshot.data![index]!)
                            : Container());
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
            }),
      ),
    );
  }
}

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
