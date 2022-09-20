import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/animations/slide_animation.dart';
import 'package:rendezvous_beta_v3/animations/slide_up.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'package:rendezvous_beta_v3/services/discover_service.dart';
import '../../models/users.dart';
import 'discover_view.dart';

class DemoProfile extends StatefulWidget {
  const DemoProfile({Key? key}) : super(key: key);

  @override
  State<DemoProfile> createState() => _DemoProfileState();
}

class _DemoProfileState extends State<DemoProfile> {
  DiscoverData get _data => DiscoverData(
      "Fake McFakerson",
      22,
      [
        "https://firebasestorage.googleapis.com/v0/b/rendezvous-beta-v3.appspot.com/o/images%2Fdemo_image%2Ffake_image.jpeg?alt=media&token=db24ad7e-40c4-4a08-b5da-7580ab602961"
      ],
      ["bar"],
      "I'm a fake person for this demo",
      "007");

  late bool _hasInteracted;

  @override
  void initState() {
    _hasInteracted = false;
    super.initState();
  }

  void _setHasInteracted() async {
    setState(() {
      _hasInteracted = true;
    });
    await UserData().updateFirstTime();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DiscoverView(
          data: _data,
          onDragUpdate: (double rating) {
            _setHasInteracted();
          },
        ),
        !_hasInteracted ? DemoOverlay(onInteraction: _setHasInteracted) : Container(),
      ],
    );
  }
}

class DemoOverlay extends StatefulWidget {
  const DemoOverlay({Key? key, required this.onInteraction}) : super(key: key);
  final void Function() onInteraction;

  @override
  State<DemoOverlay> createState() => _DemoOverlayState();
}

class _DemoOverlayState extends State<DemoOverlay> {
  late bool _complete;

  void _onComplete() {
    setState(() {
      _complete = true;
    });
  }

  @override
  void initState() {
    _complete = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onInteraction,
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _complete
                  ? const SlideUp(
                      child: Icon(
                      Icons.back_hand,
                      color: Colors.white70,
                      size: 65,
                    ))
                  : SlideAnimation(
                      child: const Icon(Icons.back_hand,
                          color: Colors.white70, size: 65),
                      complete: _onComplete),
              const SizedBox(
                height: 20,
              ),
              Text(
                  _complete
                      ? "Swipe up to see the next profile"
                      : "Move the slider right to increase your rating, move slider to the left decrease rating",
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: kTextStyle),
            ],
          ),
        ),
      ),
    );
  }
}
