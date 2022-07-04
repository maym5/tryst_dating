import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/widgets/discover_view/ratings_circle.dart';
import '../../services/discover_service.dart';
import '../profile_view/profile_view.dart';


class DiscoverView extends StatefulWidget {
  const DiscoverView({Key? key, required this.data, required this.onDragUpdate}) : super(key: key);
  final DiscoverData data;
  final void Function(double) onDragUpdate;

  @override
  _DiscoverViewState createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  late double _userRating;
  late bool _visible;
  final double _dragRadius = 20;

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _visible = true;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    double userDragDistance = details.delta.distance;
    double userDragDirection = details.delta.dx;
    bool safeToDrag = (_userRating +
        (userDragDirection.sign *
            (userDragDistance / _dragRadius))) <=
        10 &&
        _userRating +
            (userDragDirection.sign *
                (userDragDistance / _dragRadius)) >=
            0;
    if (safeToDrag) {
      setState(() {
        _userRating +=
        (userDragDirection.sign * (userDragDistance / _dragRadius));
      });
    }
    widget.onDragUpdate(_userRating);
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _visible = false;
    });
  }

  @override
  void initState() {
    _userRating = 5.0;
    _visible = false;
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
          onDragStart: _onDragStart,
          onDragUpdate: _onDragUpdate,
          onDragEnd: _onDragEnd,
        ),
        RatingsCircle(
          visible: _visible,
          userRating: _userRating,
        ),
      ],
    );
  }
}

