import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/widgets/discover_view/ratings_circle.dart';
import '../../services/discover_service.dart';
import '../profile_view/profile_view.dart';

class DiscoverView extends StatefulWidget {
  const DiscoverView(
      {Key? key,
      required this.data,
      required this.onDragUpdate,})
      : super(key: key);
  final DiscoverData data;
  final void Function(double) onDragUpdate;

  @override
  _DiscoverViewState createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  late bool _visible;

  void _onExpanded(bool expanded) {
    setState(() {
      _visible = !expanded;
    });
  }

  @override
  void initState() {
    _visible = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ProfileView(
          userPhotos: widget.data.images,
          bio: widget.data.bio,
          name: widget.data.name,
          age: widget.data.age,
          dateTypes: widget.data.dates,
          onExpanded: _onExpanded,
        ),
        RatingStack(onChanged: widget.onDragUpdate, visible: _visible),
      ],
    );
  }
}

