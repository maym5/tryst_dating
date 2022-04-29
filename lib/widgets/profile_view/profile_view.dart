import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'package:rendezvous_beta_v3/pages/discover_page.dart';
import 'package:rendezvous_beta_v3/pages/home_page.dart';
import 'package:rendezvous_beta_v3/widgets/profile_view/profile_info.dart';
import '../../models/user_images.dart';
import '../../models/users.dart';
import '../page_background.dart';
import '../round_button.dart';
import 'image_background.dart';

class UserProfile extends StatelessWidget {
  static const id = "profile";
  const UserProfile({Key? key}) : super(key: key);

  // discuss this with pulkit
  List<XFile> get _images {
    List<XFile> images = [];
    for (var image in UserImages.userImages) {
      if (image != null) {
        images.add(image);
      }
    }
    return images;
  }

  Widget _buttons(BuildContext context) => Align(
    alignment: const Alignment(0.95, -0.8),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        RoundButton(icon: Icons.edit, title: "Edit", onPressed: () {
          Navigator.pop(context);
        },),
        const SizedBox(height: 10,),
        RoundButton(icon: Icons.favorite, title: "Discover", gradient: kButtonGradient, onPressed: () {
          Navigator.pushNamed(context, HomePage.id);
        },),
      ],
    ),
  );


  @override
  Widget build(BuildContext context) {
    return PageBackground(
      body: Stack(
        children: <Widget>[
          ProfileView(
            userPhotos: UserData.imageURLs,
            bio: UserData.bio!,
            name: UserData.name!,
            age: UserData.age!,
            dateTypes: UserData.dates.toList(),
          ),
          _buttons(context)
        ],
      ),
    );
  }
}


class ProfileView extends StatefulWidget {
  const ProfileView(
      {Key? key,
      required this.userPhotos,
      required this.bio,
      required this.name,
      required this.age,
      required this.dateTypes,
      this.onDragStart,
      this.onDragUpdate,
      this.onDragEnd})
      : super(key: key);
  final List<String> userPhotos;
  final String name;
  final int age;
  final String bio;
  final List<String> dateTypes;
  final void Function(DragStartDetails)? onDragStart;
  final void Function(DragUpdateDetails)? onDragUpdate;
  final void Function(DragEndDetails)? onDragEnd;

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late bool _expanded;
  late int _index;
  double? _tapLoc;

  @override
  void initState() {
    _expanded = false;
    _index = 0;
    super.initState();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      final RenderBox box = context.findRenderObject() as RenderBox;
      final localOffset = box.globalToLocal(details.globalPosition);
      final initialTapLoc = localOffset.dx;
      _tapLoc = initialTapLoc;
      _expanded = false;
    });
  }

  void _onTapUp(TapUpDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    setState(() {
      if (_tapLoc! < box.size.width / 2) {
        if (_index - 1 >= 0) {
          _index--;
        } else {
          _index = 0;
        }
      } else {
        if (_index + 1 < widget.userPhotos.length) {
          _index++;
        } else {
          _index = widget.userPhotos.length - 1;
        }
      }
    });
  }

  void _onExpand(bool expanded) {
    setState(() => _expanded = expanded);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ImageBackground(
          isExpanded: _expanded,
          userPhotos: widget.userPhotos,
          activeIndex: _index,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onDragStart: widget.onDragStart,
          onDragUpdate: widget.onDragUpdate,
          onDragEnd: widget.onDragEnd,
        ),
        ProfileInfo(
          age: widget.age,
          name: widget.name,
          bio: widget.bio,
          onExpand: _onExpand,
          activeIndex: _index,
          dateTypes: widget.dateTypes,
        )
      ],
    );
  }
}
