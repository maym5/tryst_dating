import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import '../models/users.dart';

class DiscoverService {
  DiscoverService();
  final Map<String, dynamic> currentUserData = UserData.toJson();

  Stream<QuerySnapshot<Map>> get newDiscoverStream async* {
    FirebaseFirestore _db = FirebaseFirestore.instance;
    final discoverRef = _db.collection("userData");
    final QuerySnapshot dateMatches = await discoverRef
        .where("dates", arrayContains: currentUserData["dates"])
        .get();
    final ageMatch = await discoverRef
        .where("age", isGreaterThanOrEqualTo: currentUserData["minAge"])
        .where("age", isLessThanOrEqualTo: currentUserData["maxAge"])
        .get();
    final gender = await discoverRef
        .where("gender", arrayContainsAny: currentUserData["prefGender"])
        .get();
    final price = await discoverRef
        .where("price", isLessThanOrEqualTo: currentUserData["maxPrice"])
        .where("price", isGreaterThanOrEqualTo: currentUserData["minPrice"])
        .get();
    final notYou = await discoverRef
        .where("name", isNotEqualTo: currentUserData["name"])
        .get();
    for (var doc in dateMatches.docs) {
      if (ageMatch.docs.contains(doc) &&
          gender.docs.contains(doc) &&
          price.docs.contains(doc) &&
          notYou.docs.contains(doc)) {
        final QuerySnapshot<Map> result = doc as QuerySnapshot<Map>;
        yield result;
      }
    }
    // add current location to userData firestore
  }

  Stream<QueryDocumentSnapshot<Map>> get peopleInRange async* {
    await for (var snapshot in newDiscoverStream) {
      for (var doc in snapshot.docs) {
        final GeoPoint _geopoint = doc.data()["location"];
        if (Geolocator.distanceBetween(
                UserData.location!.latitude,
                UserData.location!.longitude,
                _geopoint.latitude,
                _geopoint.longitude) <=
            (UserData.maxDistance! * 1609.34)) {
          yield doc;
        }
      }
    }
  }

  Stream<QuerySnapshot<Map>> get discoverStream async* {
    // TODO: write real code here
    FirebaseFirestore db = FirebaseFirestore.instance;
    yield* db
        .collection("userData")
        .where("distance", isLessThanOrEqualTo: currentUserData["distance"])
        .get()
        .asStream();
  }
}
