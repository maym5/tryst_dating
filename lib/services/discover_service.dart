import 'package:cloud_firestore/cloud_firestore.dart';
import '../cloud/users.dart';

class DiscoverService {
  DiscoverService();
  final Map<String, dynamic> currentUserData = UserData.toJson();

  Future<QuerySnapshot<Map>> get discoverData async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    // final QuerySnapshot<Map<String, dynamic>> userData = await db.collection("userData").where(
    //     "distance", isLessThanOrEqualTo: data["distance"]).where(
    //     "gender", arrayContainsAny: data["prefGender"]).where(
    //     "dates", arrayContainsAny: data["dates"]).where(
    //     "age", isGreaterThanOrEqualTo: data["minAge"]).where(
    //     "age", isLessThanOrEqualTo: data["maxAge"]).where(
    //     "minPrice", isGreaterThanOrEqualTo: data["minPrice"]).where(
    //     "maxPrice", isLessThanOrEqualTo: data["maxPrice"]).get();
    final QuerySnapshot<Map<String,dynamic>> userData = await db.collection('userData').where(
        "distance", isLessThanOrEqualTo: currentUserData["distance"]).get();
    return userData;
  }

  static List<String> listToListOfStrings(List list) {
    final List<String> aListOfStrings = [];
    for (var item in list) {
      aListOfStrings.add(item.toString());
    } return aListOfStrings;
  }

  Stream get discoverStream async* {
    FirebaseFirestore db = FirebaseFirestore.instance;
    yield* db.collection('userData').where(
        "distance", isLessThanOrEqualTo: currentUserData["distance"]).get().asStream();
  }

}