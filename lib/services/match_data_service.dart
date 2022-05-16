import 'package:cloud_firestore/cloud_firestore.dart';
import "package:async/async.dart";
import 'package:rendezvous_beta_v3/services/authentication.dart';

class MatchDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<QuerySnapshot> get datesData async {
    // this grabs dates with people you liked
    return await _db
        .collection("matchData")
        .where("likeUID", isEqualTo: currentUserUID)
        .where("match", isEqualTo: true)
        .get();
  }

  // Stream<QuerySnapshot> get pendingStream async* {
  //   // this grabs people who have liked you but you haven't said yes to
  //   yield* _db
  //       .collection("matchData")
  //       .where("matchUID", isEqualTo: currentUserUID)
  //       .where("match", isEqualTo: false)
  //       .get()
  //       .asStream();
  // }

  Future<QuerySnapshot> get matchData async {
    return await _db
        .collection("matchData")
        .where("matchUID", isEqualTo: currentUserUID)
        .get();
  }

  Stream<QuerySnapshot> get matchDataStream async* {
    final Iterable<QuerySnapshot> _data = [await datesData, await matchData];
    yield* Stream.fromIterable(_data);
  }


  static void setMatchData({required String currentDiscoverUID}) {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("matchData").doc(currentUserUID! + currentDiscoverUID).set({
      "likeUID": currentUserUID,
      "matchUID": currentDiscoverUID,
      "match": false
    });
  }

  static void updateMatchData(
      {required currentDiscoverUID,
      required String dateType,
      required DateTime dateTime,
      required String venue}) {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("matchData").doc(currentDiscoverUID).update({
      "venue": venue,
      "match": true,
      "dateType": dateType,
      "dateTime": dateTime
    });
  }
}

class MatchCardData {
  MatchCardData({
    required this.name,
    this.image,
    this.dateTime,
    this.venue,
    this.dateType,
  });
  final String name;
  final String? image;
  final String? venue;
  final DateTime? dateTime;
  final String? dateType;


  static Future<MatchCardData> getData(Map<String, dynamic> data) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final String matchUID =
        data["likeUID"] == currentUserUID ? data["matchUID"] : data["likeUID"];
    final _data = await db.collection("userData").doc(matchUID).get();
    final match = _data.data();
    if (data["match"] == true) {
      return MatchCardData(
          name: match!["name"],
          venue: data["venue"],
          dateType: data["dateType"],
          dateTime: data["dateTime"],
          image: match["imageURLs"][0]);
    }
    return MatchCardData(name: match!["name"], image: match["imageURLs"][0]);
  }
}
