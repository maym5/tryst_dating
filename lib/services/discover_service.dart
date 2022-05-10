import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/users.dart';

class DiscoverService {
  DiscoverService();
  final Map<String, dynamic> currentUserData = UserData.toJson();

  // Future<QuerySnapshot<Map>> get discoverData async {
  //   FirebaseFirestore db = FirebaseFirestore.instance;
  //   final QuerySnapshot<Map<String, dynamic>> userData = await db.collection("userData").where(
  //       "distance", isLessThanOrEqualTo: currentUserData["distance"]).where(
  //       "gender", arrayContainsAny: currentUserData["prefGender"]).where(
  //       "dates", arrayContainsAny: currentUserData["dates"]).where(
  //       "age", isGreaterThanOrEqualTo: currentUserData["minAge"]).where(
  //       "age", isLessThanOrEqualTo: currentUserData["maxAge"]).where(
  //       "minPrice", isGreaterThanOrEqualTo: currentUserData["minPrice"]).where(
  //       "maxPrice", isLessThanOrEqualTo: currentUserData["maxPrice"]).get();
  //   // final QuerySnapshot<Map<String,dynamic>> userData = await db.collection('userData').where(
  //   //     "distance", isLessThanOrEqualTo: currentUserData["distance"]).get();
  //   return userData;
  // }

  Stream<QuerySnapshot<Map>> get discoverStream async* {
    FirebaseFirestore db = FirebaseFirestore.instance;
    yield* db.collection("userData").where(
        "distance", isLessThanOrEqualTo: currentUserData["distance"]).where("uid", isNotEqualTo: currentUserData).get().asStream();
  }
}