import 'package:cloud_firestore/cloud_firestore.dart';
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
    // TODO: test this, probably many bugs
    return PageBackground(
        body: FutureBuilder(
          future: MatchDataService().matchData,
          builder: (BuildContext context, AsyncSnapshot<List<MatchCardData>> snapshot) => ListView.builder(
              itemBuilder: (context, index) => MatchCard(data: snapshot.data![index]),
          ),
        )
    );
  }
}
