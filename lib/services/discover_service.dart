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

  Set<QueryDocumentSnapshot> peopleInArea(
      QuerySnapshot lat, QuerySnapshot long) {
    final Set<QueryDocumentSnapshot> result = {};
    final List<QueryDocumentSnapshot> _latDocs = lat.docs;
    final Set<String> _longUIDs = getQueryUID(long);
    for (QueryDocumentSnapshot snapshot in _latDocs) {
      if (snapshot.exists) {
        final Map _data = snapshot.data() as Map;
        if (_longUIDs.contains(_data["uid"])) {
          result.add(snapshot);
        }
      }
    }
    return result;
  }

  Stream<List<QueryDocumentSnapshot<Map>>> get discoverStream async* {
    // this does it all now
    List<QueryDocumentSnapshot<Map>> discover = [];
    FirebaseFirestore _db = FirebaseFirestore.instance;
    final discoverRef = _db.collection("userData");
    final Map<String, double> _searchRadius = _userSearchRect;
    final QuerySnapshot withinLat = await discoverRef
        .where("latitude", isGreaterThanOrEqualTo: _searchRadius["minLat"])
        .where("latitude", isLessThanOrEqualTo: _searchRadius["maxLat"])
        .get();

    final QuerySnapshot withinLong = await discoverRef
        .where("longitude", isGreaterThanOrEqualTo: _searchRadius["minLon"])
        .where("longitude", isLessThanOrEqualTo: _searchRadius["maxLon"])
        .get();
    final Set<QueryDocumentSnapshot> areaMatch =
        peopleInArea(withinLat, withinLong);

    final QuerySnapshot dateMatches = await discoverRef
        .where("dates", arrayContainsAny: currentUserData["dates"])
        .get();
    final Set<String> dateMatchesUID = getQueryUID(dateMatches);

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

    final alreadySeen = await discoverRef
        .doc(AuthenticationService.currentUserUID)
        .collection("matches")
        .where("seen", isEqualTo: true)
        .get();
    final Set<String> alreadySeenUID =
        getQueryUID(alreadySeen, matchData: true);

    final inAgeRange = await discoverRef
        .where("age", isGreaterThanOrEqualTo: currentUserData["minAge"])
        .where("age", isLessThanOrEqualTo: currentUserData["maxAge"])
        .get();
    final Set<String> inAgeRangeUID = getQueryUID(inAgeRange);
    
    final matchTheirPref = await discoverRef.where("prefGender", arrayContains: currentUserData["gender"]).get();
    final Set<String> matchTheirPrefUID = getQueryUID(matchTheirPref);

    // check that they aren't matched
    for (QueryDocumentSnapshot doc in areaMatch) {
      final Map _data = doc.data() as Map;
      final _uid = _data["uid"];
      if (_uid != AuthenticationService.currentUserUID &&
          dateMatchesUID.contains(_uid) &&
          ageMatchUID.contains(_uid) &&
          genderMatchUID.contains(_uid) &&
          (maxPriceUID.contains(_uid) || minPriceUID.contains(_uid)) &&
          inAgeRangeUID.contains(_uid) &&
          matchTheirPrefUID.contains(_uid) &&
          !alreadySeenUID.contains(_uid)) {
        final QueryDocumentSnapshot<Map> result =
            doc as QueryDocumentSnapshot<Map>;
        discover.add(result);
        yield discover;
      }
    }
  }

  Map<String, double> get _userSearchRect {
    try {
      final double _radius = UserData.maxDistance! /
          3958.8; // the radius of earth in miles is 3958.8
      final double _minLat = UserData.location!.latitude - _radius;
      final double _maxLat = UserData.location!.latitude + _radius;
      final double _deltaLon =
          asin(sin(_radius) / cos(UserData.location!.latitude));
      final _minLon = UserData.location!.longitude - _deltaLon.abs();
      final _maxLon = UserData.location!.longitude + _deltaLon.abs();
      return {
        "minLat": _minLat,
        "maxLat": _maxLat,
        "minLon": _minLon,
        "maxLon": _maxLon
      };
    } catch (e) {
      return {
        "minLat": 0.0,
        "maxLat": 0.0,
        "minLon": 0.0,
        "maxLon": 0.0,
      };
    }
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
