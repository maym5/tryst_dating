import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/widgets/match_card.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';

class MatchPage extends StatelessWidget {
  static const id = "match_page";
  const MatchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageBackground(
        body: Center(
          child: MatchCard(
            data: MatchCardData(name: "Jamie"),
          ),
        ),
    );
  }
}

