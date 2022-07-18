import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/animations/bounce_animation.dart';
import 'package:rendezvous_beta_v3/models/dates_model.dart';
import 'package:rendezvous_beta_v3/services/match_data_service.dart';
import 'package:rendezvous_beta_v3/widgets/profile_view/profile_info.dart';

class MatchTile extends StatefulWidget {
  const MatchTile({Key? key, required this.data}) : super(key: key);
  final DateData data;

  @override
  State<MatchTile> createState() => _MatchTileState();
}

class _MatchTileState extends State<MatchTile> with TickerProviderStateMixin {
  late final AnimationController _controller;


  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) async {
    _controller.reverse();
    DatesModel(dateData: widget.data).getDate(context);
  }

  Widget get _nameAndAge => Align(
      child: Padding(
        child: NameAndAge(
          name: widget.data.name,
          age: widget.data.age!,
          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        ),
        padding: const EdgeInsets.only(bottom: 15),
      ),
      alignment: Alignment.bottomLeft);

  Widget get _backgroundImage => ClipRRect(
        child: Image.network(widget.data.image!, fit: BoxFit.cover),
        borderRadius: BorderRadius.circular(25),
      );

  Widget get _stack => Stack(
        fit: StackFit.expand,
        children: [_backgroundImage, _nameAndAge],
      );

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BounceAnimation(
      controller: _controller,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        child: Container(
          width: 150,
          height: 375,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
          child: _stack,
        ),
      ),
    );
  }
}
