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

  @override
  Widget build(BuildContext context) {
    // TODO: test this, probably many bugs
    return PageBackground(
      body: SafeArea(
        child: StreamBuilder(
            stream: MatchDataService().matchDataStream,
            builder:
                (BuildContext context, AsyncSnapshot<List<MatchCardData>> snapshot) {
              if (snapshot.hasData && !snapshot.hasError) {
                return ListView.builder(
                  itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) => MatchCard(data: snapshot.data![index])
                );
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
