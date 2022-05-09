import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/widgets/match_card.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';

class MatchPage extends StatefulWidget {
  static const id = "match_page";
  const MatchPage({Key? key}) : super(key: key);

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  late List<Map<String, dynamic>> _matches;
  late List<Map<String, dynamic>> _upcomingDates;
  late List<Map<String, dynamic>> _pastDates;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _getMatchData() {

  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
        body: ListView.builder(
            itemBuilder: (context, index) => Container(),
        )
    );
  }
}

// dateTime: DateTime(2022, 6, 6, 6), dateType: "Dinner", venue: "Mike's Fake Restaurant"