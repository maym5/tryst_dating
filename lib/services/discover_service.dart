import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rendezvous_beta_v3/services/authentication_service.dart';
import '../models/users.dart';
import 'dart:math';

class DiscoverService {
  DiscoverService();
  final Map<String, dynamic> currentUserData = UserData.toJson();

  Set<String> getQueryUID(QuerySnapshot snapshot, {bool matchData = false}) {
    final Set<String> uids = {};
    final List<QueryDocumentSnapshot> _data = snapshot.docs;
    for (var doc in _data) {
      if (!matchData) {
        final Map documentData = doc.data() as Map;
        uids.add(documentData["uid"]);
      } else {
        final Map documentData = doc.data() as Map;
        uids.add(documentData["matchUID"]);
      }
    }
    return uids;
  }

  Stream<List<QueryDocumentSnapshot<Map>>> get discoverStreamTwo async* {
    // this does it all now
    List<QueryDocumentSnapshot<Map>> discover = [];
    FirebaseFirestore _db = FirebaseFirestore.instance;
    final discoverRef = _db.collection("userData");
    final Map<String, double> _searchRadius = _userSearchRect;

    final QuerySnapshot withinLat = await discoverRef
        .where("latitude", isGreaterThan: _searchRadius["minLat"])
        .where("latitude", isLessThan: _searchRadius["maxLat"])
        .get();
    final Set<String> withinLatUID = getQueryUID(withinLat);

    final QuerySnapshot withinLong = await discoverRef
        .where("longitude", isGreaterThan: _searchRadius["minLon"])
        .where("longitude", isLessThan: _searchRadius["maxLon"])
        .get();
    final Set<String> withinLongUID = getQueryUID(withinLong);

    final QuerySnapshot dateMatches = await discoverRef
        .where("dates", arrayContainsAny: currentUserData["dates"])
        .get();

    final ageMatch = await discoverRef
        .where("age", isGreaterThanOrEqualTo: currentUserData["minAge"])
        .where("age", isLessThanOrEqualTo: currentUserData["maxAge"])
        .get();
    final Set<String> ageMatchUID = getQueryUID(ageMatch);

    final gender = await discoverRef
        .where("gender", whereIn: currentUserData["prefGender"])
        .get();
    final Set<String> genderMatchUID = getQueryUID(gender);

    final maxPrice = await discoverRef
        .where("maxPrice", isLessThanOrEqualTo: currentUserData["maxPrice"])
        .get();
    final Set<String> maxPriceUID = getQueryUID(maxPrice);
    final minPrice = await discoverRef
        .where("minPrice", isLessThanOrEqualTo: currentUserData["maxPrice"])
        .get();
    final Set<String> minPriceUID = getQueryUID(minPrice);

    final notYou = await discoverRef
        .where("uid", isNotEqualTo: currentUserData["uid"])
        .get();
    final Set<String> notYouUID = getQueryUID(notYou);

    final alreadySeen = await discoverRef
        .doc(AuthenticationService.currentUserUID)
        .collection("matches")
        .where("seen", isEqualTo: true)
        .get();
    final Set<String> alreadySeenUID =
        getQueryUID(alreadySeen, matchData: true);

    // check that they aren't matched
    for (QueryDocumentSnapshot doc in dateMatches.docs) {
      final Map _data = doc.data() as Map;
      final _uid = _data["uid"];
      // withinLatUID.contains(_uid) &&
      //     withinLongUID.contains(_uid) &&
      if (
      withinLatUID.contains(_uid) &&
          withinLongUID.contains(_uid) &&
          ageMatchUID.contains(_uid) &&
          genderMatchUID.contains(_uid) &&
          (maxPriceUID.contains(_uid) || minPriceUID.contains(_uid)) &&
          notYouUID.contains(_uid) &&
          !alreadySeenUID.contains(_uid)) {
        final QueryDocumentSnapshot<Map> result =
            doc as QueryDocumentSnapshot<Map>;
        if (await youMatchTheirPreferences(_uid)) {
          discover.add(result);
          yield discover;
        }
      }
    }
  }

  Map<String, double> get _userSearchRect {
    final double _radius = UserData.maxDistance! /
        3958.8; // the radius of earth in miles is 3958.8
    final double _minLat = UserData.location!.latitude - _radius;
    final double _maxLat = UserData.location!.latitude + _radius;
    final double _deltaLon =
        asin(sin(_radius) / cos(UserData.location!.latitude));
    final _minLon = UserData.location!.longitude - _deltaLon;
    final _maxLon = UserData.location!.longitude + _deltaLon;
    return {
      "minLat": _minLat,
      "maxLat": _maxLat,
      "minLon": _minLon,
      "maxLon": _maxLon
    };
  }

  Future<bool> youMatchTheirPreferences(String uid) async {
    FirebaseFirestore _db = FirebaseFirestore.instance;
    final DocumentSnapshot snapshot =
        await _db.collection("userData").doc(uid).get();
    final Map<String, dynamic> _data = snapshot.data() as Map<String, dynamic>;
    final List _prefGender = _data["prefGender"] as List;
    if (currentUserData["age"] >= _data["minAge"] &&
        currentUserData["age"] <= _data["maxAge"] &&
        _prefGender.contains(currentUserData["gender"])) {
      return true;
    }
    return false;
  }

  // Stream<List<QueryDocumentSnapshot<Map>>> get discoverStream async* {
  //   List<QueryDocumentSnapshot<Map>> result = [];
  //   await for (QueryDocumentSnapshot<Map> doc in discoverStreamTwo) {
  //     final GeoPoint? _geoPoint = doc.data()["location"];
  //     if (_geoPoint != null) {
  //       if (Geolocator.distanceBetween(
  //               UserData.location!.latitude,
  //               UserData.location!.longitude,
  //               _geoPoint.latitude,
  //               _geoPoint.longitude) <=
  //           (UserData.maxDistance! * 1609.34)) {
  //         result.add(doc);
  //         yield result;
  //       }
  //     }
  //   }
  // }
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
