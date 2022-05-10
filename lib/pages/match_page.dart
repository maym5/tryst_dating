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
        body: StreamBuilder(
          stream: MatchDataService().matchDataStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) => ListView.builder(
            itemCount: snapshot.data?.size == 0 ? 1 : snapshot.data?.size,
              itemBuilder: (context, index) {
                if (snapshot.hasData) {
                  final List<Map<String, dynamic>> documents = snapshot
                      .data!.docs
                      .map((doc) => doc.data() as Map<String, dynamic>)
                      .toList();
                  if (documents.isNotEmpty) {
                    final data = MatchCardData.getData(documents[index]);
                    return MatchCard(data: data);
                  } else {
                    return const Center(child: Text("Such empty, get swiping!"));
                  }
                } return const Center(child: Text("Such empty, get swiping!"));
              }
          ),
        )
    );
  }
}
