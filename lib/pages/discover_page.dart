import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'package:rendezvous_beta_v3/models/user_images.dart';
import 'package:rendezvous_beta_v3/widgets/discover_view/discover_view.dart';
import 'package:rendezvous_beta_v3/widgets/like_widget.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';
import '../services/discover_service.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import "dart:io";

class DiscoverPage extends StatefulWidget {
  static const id = "discover_page";
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  late double _userRating;
  late int _previousPage;
  late PageController _pageController;
  late ValueNotifier<double> _animation;

  void _onScroll() {
    // made change must test
    // works but not ideal
    if (_pageController.page!.toInt() == _pageController.page) {
      _previousPage = _pageController.page!.toInt();
    } else if (_pageController.page! - _previousPage >= 0.3) {
      _animation.value = 0;
    } else {
      _animation.value = (_pageController.page! - _previousPage);
    }
  }

  @override
  void initState() {
    _animation = ValueNotifier(0);
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 1,
    )..addListener(_onScroll);
    _animation.value = _pageController.initialPage.toDouble();
    _previousPage = _pageController.initialPage;
    _userRating = 5.0;
    super.initState();
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    super.dispose();
  }

  void setUserRating(double userRating) {
    setState(() {
      _userRating = userRating;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      body: StreamBuilder(
        stream: DiscoverService().discoverStream,
        builder: (context, AsyncSnapshot<QuerySnapshot<Map>> snapshot) =>
            PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data?.size, // <- bug fix here
                itemBuilder: (BuildContext context, int index) {
                  if (snapshot.hasData && !snapshot.hasError) {
                    final List<Map<String, dynamic>> documents = snapshot
                        .data!.docs
                        .map((doc) => doc.data() as Map<String, dynamic>)
                        .toList();
                    final Map<String, dynamic> currentDoc = documents[index];
                    return Stack(
                      children: [
                        DiscoverView(
                          data: DiscoverData.getDiscoverData(currentDoc),
                          onDragUpdate: setUserRating,
                        ),
                        Center(
                          child: LikeWidget(
                            animation: _animation,
                            userRating: _userRating,
                          ),
                        ),
                      ],
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return RippleAnimation(
                      color: Colors.redAccent,
                      child: const DiscoverLoadingAvatar(),
                      repeat: true,
                      ripplesCount: 6,
                      minRadius: 80,
                    );
                  } else {
                    return Center(
                      child: Text(
                          "There has been an error try restarting the app",
                          style: kTextStyle),
                    );
                  }
                }),
      ),
    );
  }
}

class DiscoverData {
  DiscoverData(this.name, this.age, this.images, this.dates, this.bio);
  final String name;
  final int age;
  final List<String> dates;
  final List<String> images;
  final String bio;

  static List<String> listToListOfStrings(List list) {
    final List<String> aListOfStrings = [];
    for (var item in list) {
      aListOfStrings.add(item.toString());
    }
    return aListOfStrings;
  }

  factory DiscoverData.getDiscoverData(Map<String, dynamic> data) {
    final List<String> _dates = listToListOfStrings(data["dates"]);
    final List<String> _images = listToListOfStrings(data["imageURLs"]);
    return DiscoverData(
        data["name"], data["age"], _images, _dates, data["bio"]);
  }
}

class DiscoverLoadingAvatar extends StatelessWidget {
  const DiscoverLoadingAvatar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircleAvatar(
        radius: 50,
        backgroundImage: FileImage(File(UserImages.userImages[0]!.path)),
      ),
    );
  }
}
