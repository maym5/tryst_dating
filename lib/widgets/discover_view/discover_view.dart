import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/widgets/discover_view/ratings_circle.dart';

import '../profile_view/profile_view.dart';



// class TestDiscover extends StatelessWidget {
//   static const id = "test_discover";
//   const TestDiscover({Key? key}) : super(key: key);
//   // test code no need to panic
//
//   List<XFile> get _images {
//     List<XFile> images = [];
//     for (var image in UserImages.userImages) {
//       if (image != null) {
//         images.add(image);
//       }
//     }
//     return images;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return PageBackground(
//         body: DiscoverView(
//           name: UserData.name!,
//           age: UserData.age!,
//           dateTypes: UserData.dates.toList(),
//           bio: UserData.bio!,
//           images: _images,
//         ),
//     );
//   }
// }


class DiscoverView extends StatefulWidget {
  const DiscoverView(
      {Key? key,
      required this.dateTypes,
      required this.images,
      required this.age,
      required this.name,
      required this.bio})
      : super(key: key);
  final String name;
  final int age;
  final String bio;
  final List images;
  final List<String> dateTypes;

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
          userPhotos: widget.images,
          bio: widget.bio,
          name: widget.name,
          age: widget.age,
          dateTypes: widget.dateTypes,
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
