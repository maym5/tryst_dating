import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rendezvous_beta_v3/animations/bounce_animation.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'package:rendezvous_beta_v3/widgets/profile_view/profile_info.dart';
import '../../cloud_functions/users.dart';
import '../../layouts/page_background.dart';
import '../../cloud_functions/user_images.dart';
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
          // push to discover
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
            userPhotos: _images,
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

class RoundButton extends StatefulWidget {
  const RoundButton({Key? key, required this.icon, required this.title, required this.onPressed, this.gradient}) : super(key: key);
  final IconData icon;
  final String title;
  final void Function() onPressed;
  final LinearGradient? gradient;

  @override
  State<RoundButton> createState() => _RoundButtonState();
}

class _RoundButtonState extends State<RoundButton> with TickerProviderStateMixin{
  late final AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    super.initState();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      child: BounceAnimation(
        controller: _controller,
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: widget.gradient,
            color: kInactiveColor
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(widget.icon, size: 30, color: Colors.white,),
                FittedBox(child: Text(widget.title, style: kTextStyle.copyWith(fontSize: 20),)),
              ],
            ),
          ),
        ),
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
  final List userPhotos;
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
