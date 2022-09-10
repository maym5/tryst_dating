import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'package:rendezvous_beta_v3/models/dates_model.dart';
import 'package:rendezvous_beta_v3/services/authentication_service.dart';
import 'package:rendezvous_beta_v3/services/match_data_service.dart';
import 'package:rendezvous_beta_v3/widgets/discover_view/demo_profile.dart';
import 'package:rendezvous_beta_v3/widgets/discover_view/discover_view.dart';
import 'package:rendezvous_beta_v3/widgets/like_widget.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';
import '../models/users.dart';
import '../services/discover_service.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

class DiscoverPage extends StatefulWidget {
  static const id = "discover_page";
  const DiscoverPage({Key? key, this.firstTime = false}) : super(key: key);
  final bool firstTime;

  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  late double _userRating;
  late int _previousPage;
  late PageController _pageController;
  late ValueNotifier<double> _animation;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late Map<String, dynamic> _displayedDoc;
  late Map<String, dynamic> _currentDoc;
  final Stream<List<QueryDocumentSnapshot<Map>>> _discoverStream =
      DiscoverService().discoverStream;
  DiscoverData get _displayedDiscoverData =>
      DiscoverData.getDiscoverData(_displayedDoc);
  DiscoverData get _currentDiscoverData =>
      DiscoverData.getDiscoverData(_currentDoc);
  String get _currentUID => _currentDiscoverData.uid;
  ScrollPhysics _physics = const AlwaysScrollableScrollPhysics();

  void _onScroll() {
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

  Widget get waitingAnimation => RippleAnimation(
        color: Colors.redAccent,
        child: const DiscoverLoadingAvatar(),
        repeat: true,
        ripplesCount: 4,
        minRadius: 80,
      );

  Widget get noDataMessage => Center(
        child: Text(
          "You've seen everyone in your area! We just launched so check in later or try increasing your search distance to keep rating",
          textAlign: TextAlign.center,
          style: kTextStyle,
          softWrap: true,
        ),
      );

  Widget get errorMessage => Center(
        child: Text("There has been an error, try restarting the app",
            textAlign: TextAlign.center, style: kTextStyle),
      );

  void _updateCurrentDiscoverData(
      int page, AsyncSnapshot<List<QueryDocumentSnapshot<Map>>> snapshot) {
    setState(() {
      _currentDoc = snapshot.data![page].data() as Map<String, dynamic>;
    });
  }

  Future<bool> get matchExists async {
    DocumentSnapshot _matchSnapShot = await _db
        .collection("userData")
        .doc(AuthenticationService.currentUserUID)
        .collection("matches")
        .doc(_currentUID)
        .get();
    return _matchSnapShot.exists && _matchSnapShot.data() != null;
  }

  Future<void> get date async {
    await DatesModel(discoverData: _currentDiscoverData)
        .getDate(context, userRating: _userRating);
  }

  Future<void> get createNewMatch async {
    await MatchDataService.setMatchData(
        currentDiscoverUID: _currentUID,
        userRating: _userRating,
        image: _currentDiscoverData.images[0],
        name: _currentDiscoverData.name,
        age: _currentDiscoverData.age,
        dateTypes: _currentDiscoverData.dates);
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      body: StreamBuilder(
        stream: DiscoverService().discoverStream,
        builder: (context,
            AsyncSnapshot<List<QueryDocumentSnapshot<Map>>> snapshot) {
          if (snapshot.hasData && !snapshot.hasError) {
            return PageView.builder(
                onPageChanged: (int page) async {
                  if (_userRating > 5 && await matchExists) {
                    await date;
                  } else {
                    await createNewMatch;
                  }
                  if (page < snapshot.data!.length) {
                    _updateCurrentDiscoverData(page, snapshot);
                  } else {
                    setState(
                        () => _physics = const NeverScrollableScrollPhysics());
                  }
                },
                controller: _pageController,
                physics: _physics,
                scrollDirection: Axis.vertical,
                itemCount: widget.firstTime
                    ? snapshot.data!.length + 2
                    : snapshot.data!.length + 1,
                itemBuilder: (context, index) {
                  if (index < snapshot.data!.length && !widget.firstTime) {
                    _displayedDoc =
                        snapshot.data![index].data() as Map<String, dynamic>;
                    if (index == 0) {
                      _currentDoc =
                          snapshot.data![0].data() as Map<String, dynamic>;
                    }
                    return Stack(
                      children: [
                        DiscoverView(
                          data: _displayedDiscoverData,
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
                  } else if (widget.firstTime) {
                    if (index == 0) {
                      return const DemoProfile();
                    } else {
                      if (index < snapshot.data!.length) {
                        _displayedDoc = snapshot.data![index - 1].data()
                            as Map<String, dynamic>;
                        if (index == 1) {
                          _currentDoc =
                              snapshot.data![0].data() as Map<String, dynamic>;
                        }
                        return Stack(
                          children: [
                            DiscoverView(
                              data: _displayedDiscoverData,
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
                      } else {
                        return noDataMessage;
                      }
                    }
                  } else {
                    return noDataMessage;
                  }
                });
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return waitingAnimation;
          } else if (!snapshot.hasData) {
            if (widget.firstTime) {
              return PageView(
                scrollDirection: Axis.vertical,
                children: [const DemoProfile(), noDataMessage],
              );
            }
            return noDataMessage;
          } else {
            if (widget.firstTime) {
              return PageView(
                scrollDirection: Axis.vertical,
                children: [const DemoProfile(), errorMessage],
              );
            }
            return errorMessage;
          }
        },
      ),
    );
  }
}

class DiscoverLoadingAvatar extends StatelessWidget {
  const DiscoverLoadingAvatar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: kPopUpColor),
        child: CircleAvatar(
          backgroundColor: kGreyWithAlpha,
          radius: 50,
          backgroundImage: NetworkImage(UserData.imageURLs[0]),
        ),
      ),
    );
  }
}
