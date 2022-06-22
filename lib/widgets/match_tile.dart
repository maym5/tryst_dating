import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/services/match_data_service.dart';
import 'package:rendezvous_beta_v3/widgets/profile_view/profile_info.dart';

class MatchTile extends StatefulWidget {
  const MatchTile({Key? key, required this.data}) : super(key: key);
  final MatchCardData data;

  @override
  State<MatchTile> createState() => _MatchTileState();
}

class _MatchTileState extends State<MatchTile> {

  Widget get _nameAndAge => Align(child: NameAndAge(name: widget.data.name, age: widget.data.age!), alignment: Alignment.bottomLeft);

  Widget get _backgroundImage => Image.network(widget.data.image!, fit: BoxFit.cover);

  Widget get _stack => Stack(
    fit: StackFit.expand,
    children: [
      _backgroundImage,
      _nameAndAge
    ],
  );


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 375,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15)
      ),
      child: _stack,
    );
  }
}
