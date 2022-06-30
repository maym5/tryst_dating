import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rendezvous_beta_v3/services/authentication.dart';
import '../models/users.dart';

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

  Stream<QueryDocumentSnapshot<Map>> get preferenceMatches async* {
    FirebaseFirestore _db = FirebaseFirestore.instance;
    final discoverRef = _db.collection("userData");
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
        .where("minPrice", isGreaterThanOrEqualTo: currentUserData["minPrice"])
        .get();
    final Set<String> minPriceUID = getQueryUID(minPrice);

    final notYou = await discoverRef
        .where("uid", isNotEqualTo: currentUserData["uid"])
        .get();
    final Set<String> notYouUID = getQueryUID(notYou);

    final alreadySeen =
        await discoverRef.doc(currentUserUID).collection("matches").get();
    final Set<String> alreadySeenUID = getQueryUID(alreadySeen, matchData: true);

    // check that they aren't matched
    for (QueryDocumentSnapshot doc in dateMatches.docs) {
      final Map _data = doc.data() as Map;
      final _uid = _data["uid"];
      if (ageMatchUID.contains(_uid) &&
          genderMatchUID.contains(_uid) &&
          maxPriceUID.contains(_uid) &&
          minPriceUID.contains(_uid) &&
          notYouUID.contains(_uid) &&
          !alreadySeenUID.contains(_uid)) {
        final QueryDocumentSnapshot<Map> result =
            doc as QueryDocumentSnapshot<Map>;
        yield result;
      }
    }
  }

  Stream<List<QueryDocumentSnapshot<Map>>> get discoverStream async* {
    // TODO: big todo fix this
    List<QueryDocumentSnapshot<Map>> result = [];
    try {
      await for (QueryDocumentSnapshot<Map> doc in preferenceMatches) {
        final GeoPoint? _geoPoint = doc.data()["location"];
        if (_geoPoint != null) {
          if (Geolocator.distanceBetween(
                  UserData.location!.latitude,
                  UserData.location!.longitude,
                  _geoPoint.latitude,
                  _geoPoint.longitude) <=
              (UserData.maxDistance! * 1609.34)) {
            result.add(doc);
            yield result;
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }
}
