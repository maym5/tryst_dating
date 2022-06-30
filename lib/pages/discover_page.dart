import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'package:rendezvous_beta_v3/dialogues/pick_another_day_dialogue.dart';
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
  // TODO: handle open hours
  late double _userRating;
  late int _previousPage;
  late PageController _pageController;
  late ValueNotifier<double> _animation;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String currentDiscoverUID;
  late DiscoverData _currentDiscoverData;
  DateTime? _dateTime;

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

  Widget get _waitingAnimation => RippleAnimation(
        color: Colors.orangeAccent,
        child: const DiscoverLoadingAvatar(),
        repeat: true,
        ripplesCount: 4,
        minRadius: 80,
      );

  Widget get _noDataMessage => Center(
        child: Text(
          "There's no one in your area, try increasing your search distance to keep rating",
          textAlign: TextAlign.center,
          style: kTextStyle,
          softWrap: true,
        ),
      );

  Widget get _errorMessage => Center(
        child: Text("There has been an error, try restarting the app",
            textAlign: TextAlign.center, style: kTextStyle),
      );

  Future<void> onPageChanged(int page) async {
    if (_userRating > 5) {
      QuerySnapshot matchSnapshot = await _firestore
          .collection("matchData")
          .where("matchUID", isEqualTo: currentUserUID)
          .where("likeUID", isEqualTo: currentDiscoverUID)
          .get();
      if (matchSnapshot.size != 0) {
        // (1) get overlapping dateTypes between both users (userData pull)
        // do this in the build someplace and save to local varaible
        // (2) select one of said dateTypes and feed it to the google places service
        // (3) use returned data to alter matchData document in the cloud.
        // dates they share in common
        List<String> commonDateTypes = _currentDiscoverData.dates
            .where((element) => UserData.dates.contains(element))
            .toList();
        final String _dateType = commonDateTypes[
        Random().nextInt(commonDateTypes.length)];
        final Map _venueData = await GooglePlacesService(
            venueType:
            _dateType) // might be empty handle that case
            .venue;
        final DocumentSnapshot _matchSnapshot = await _firestore
            .collection("userData")
            .doc(currentDiscoverUID)
            .get();
        final Map _matchData = _matchSnapshot.data() as Map;
        if (_venueData["status"] == "OK") {
          await DateTimeDialogue(setDateTime: setDateTime)
              .buildCalendarDialogue(context,
              matchName: _matchData["name"],
              venueName: _venueData["name"]);
          if (_dateTime != null &&
              await GooglePlacesService.checkDateTime(
                  _dateTime!, _venueData)) {
            await MatchDataService.updateMatchData(
                otherUserUID: currentDiscoverUID,
                dateType: _dateType,
                dateTime: _dateTime!,
                venue: _venueData["name"],
              userRating: _userRating
            );
          }
        } else {
          // what do we do if api fails ??
          if (!await GooglePlacesService.checkDateTime(
              _dateTime!, _venueData)) {
            await DateTimeDialogue(setDateTime: setDateTime)
                .buildCalendarDialogue(context,
                venueName: _venueData["name"],
                pickAnother: true,
                matchName: _matchData["name"]);
          } else {
            // error dialgoue
          }
        }
      } else {
        await MatchDataService.setMatchData(
            currentDiscoverUID: currentDiscoverUID,
          userRating: _userRating,
          image: _currentDiscoverData.images[0],
          name: _currentDiscoverData.name,
          age: _currentDiscoverData.age
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      body: StreamBuilder(
        stream: DiscoverService().discoverStream,
        builder: (context,
                AsyncSnapshot<List<QueryDocumentSnapshot<Map>>> snapshot) =>
            PageView.builder(
                onPageChanged: onPageChanged,
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data?.length,
                itemBuilder: (BuildContext context, int index) {
                  if (snapshot.hasData && !snapshot.hasError) {
                    final currentDoc =
                        snapshot.data![index].data() as Map<String, dynamic>;
                    _currentDiscoverData =
                        DiscoverData.getDiscoverData(currentDoc);
                    currentDiscoverUID = _currentDiscoverData.uid;
                    return Stack(
                      children: [
                        DiscoverView(
                          data: _currentDiscoverData,
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
                    // problem here
                    return _waitingAnimation;
                  } else if (!snapshot.hasData) {
                    return _noDataMessage;
                  } else {
                    return _errorMessage;
                  }
                }),
      ),
    );
  }
}

class DiscoverData {
  DiscoverData(
      this.name, this.age, this.images, this.dates, this.bio, this.uid);
  final String name;
  final int age;
  final List<String> dates;
  final List<String> images;
  final String bio;
  final String uid;

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
        data["name"], data["age"], _images, _dates, data["bio"], data["uid"]);
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
