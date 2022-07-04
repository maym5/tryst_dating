import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'package:rendezvous_beta_v3/services/authentication.dart';
import 'package:rendezvous_beta_v3/services/google_places_service.dart';
import 'package:rendezvous_beta_v3/services/match_data_service.dart';
import 'package:rendezvous_beta_v3/widgets/discover_view/discover_view.dart';
import 'package:rendezvous_beta_v3/widgets/like_widget.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';
import '../dialogues/date_time_dialogue.dart';
import '../models/users.dart';
import '../services/discover_service.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'dart:math';

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
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  DateTime? _dateTime;
  late Map<String, dynamic> _displayedDoc;
  late Map<String, dynamic> _currentDoc;
  final Stream<List<QueryDocumentSnapshot<Map>>> _discoverStream = DiscoverService().discoverStream;
  DiscoverData get _displayedDiscoverData =>
      DiscoverData.getDiscoverData(_displayedDoc);
  DiscoverData get _currentDiscoverData =>
      DiscoverData.getDiscoverData(_currentDoc);
  String get _currentUID => _currentDiscoverData.uid;

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

  void setDateTime(DateTime date, TimeOfDay time) {
    setState(() {
      _dateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Widget get waitingAnimation => RippleAnimation(
        color: Colors.orangeAccent,
        child: const DiscoverLoadingAvatar(),
        repeat: true,
        ripplesCount: 4,
        minRadius: 80,
      );

  Widget get noDataMessage => Center(
        child: Text(
          "There's no one in your area, try increasing your search distance to keep rating",
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
    List<String> commonDateTypes = _currentDiscoverData.dates
        .where((element) => UserData.dates.contains(element))
        .toList();
    final String _dateType =
        commonDateTypes[Random().nextInt(commonDateTypes.length)];
    final Map _venueData = await GooglePlacesService(
            venueType: _dateType) // might be empty handle that case
        .venue;
    final DocumentSnapshot _matchSnapshot =
        await _db.collection("userData").doc(_currentUID).get();
    final Map _matchData = _matchSnapshot.data() as Map;
    if (_venueData["status"] == "OK") {
      await DateTimeDialogue(setDateTime: setDateTime).buildCalendarDialogue(
          context,
          matchName: _matchData["name"],
          venueName: _venueData["name"]);
      if (_dateTime != null &&
          await GooglePlacesService.checkDateTime(_dateTime!, _venueData)) {
        await MatchDataService.updateMatchData(
            otherUserUID: _currentUID,
            dateType: _dateType,
            dateTime: _dateTime!,
            venue: _venueData["name"],
            userRating: _userRating);
      }
    } else {
      if (!await GooglePlacesService.checkDateTime(_dateTime!, _venueData)) {
        await DateTimeDialogue(setDateTime: setDateTime).buildCalendarDialogue(
            context,
            venueName: _venueData["name"],
            pickAnother: true,
            matchName: _matchData["name"]);
      } else {
        print("there was an error");
        // TODO: error dialogue
      }
    }
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
        stream: _discoverStream,
        builder: (context,
                AsyncSnapshot<List<QueryDocumentSnapshot<Map>>> snapshot) =>
            PageView.builder(
                onPageChanged: (int page) async {
                  if (_userRating > 5 && await matchExists) {
                    await date;
                  } else {
                    await createNewMatch;
                  }
                  _updateCurrentDiscoverData(page, snapshot);
                },
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data?.length,
                itemBuilder: (BuildContext context, int index) {
                  if (snapshot.hasData && !snapshot.hasError) {
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
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return waitingAnimation;
                  } else if (!snapshot.hasData) {
                    return noDataMessage;
                  } else {
                    return errorMessage;
                  }
                }),
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
        decoration: const BoxDecoration(
            shape: BoxShape.circle, gradient: kButtonGradient),
        child: CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(UserData.imageURLs[0]),
        ),
      ),
    );
  }
}
