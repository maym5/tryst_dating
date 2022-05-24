import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:rendezvous_beta_v3/services/match_data_service.dart';
import 'package:rendezvous_beta_v3/widgets/match_card.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';

import '../constants.dart';

class MatchPage extends StatefulWidget {
  static const id = "match_page";
  const MatchPage({Key? key}) : super(key: key);

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {

  void checkThing() async {
    final value = await MatchDataService().newDatesData;
    final anotherValue = await MatchDataService().newMatchData;
    print(value.length);
    print(anotherValue.length);
  }

  @override
  void initState() {
    checkThing();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: test this, probably many bugs
    return PageBackground(
      body: SafeArea(
        child: StreamBuilder(
            stream: MatchDataService().newMatchDataStream,
            builder:
                (BuildContext context, AsyncSnapshot<MatchCardData> snapshot) {
              if (snapshot.hasData && !snapshot.hasError) {
                return MatchCard(data: snapshot.data!);
              } else if (!snapshot.hasData) {
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
// StreamBuilder(
// stream: MatchDataService().matchDataStream,
// builder: (BuildContext context,
//     AsyncSnapshot<QuerySnapshot<Object?>> snapshot) =>
// ListView.builder(
// itemCount: snapshot.data?.size == 0 ? 1 : snapshot.data?.size,
// itemBuilder: (context, index) {
// if (snapshot.hasData && !snapshot.hasError) {
// final List<Map<String, dynamic>> documents = snapshot
//     .data!.docs
//     .map((doc) => doc.data() as Map<String, dynamic>)
//     .toList();
// if (documents.isNotEmpty) {
// final Future<MatchCardData> data =
// MatchCardData.getData(documents[index]);
// return FutureBuilder(
// future: data,
// builder: (context,
// AsyncSnapshot<MatchCardData> futureSnap) {
// if (futureSnap.hasData) {
// if (futureSnap.connectionState ==
// ConnectionState.done) {
// return MatchCard(data: futureSnap.data!);
// } else {
// return Container();
// }
// } else {
// return Container();
// }
// });
// }
// }
// return Container(
// alignment: Alignment.center,
// height: MediaQuery.of(context).size.height,
// child: const Text("Such empty, get swiping!"),
// );
// }),
// )
