import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<List<MatchCardData>> get newMatchData async {
    List<MatchCardData> result = [];
    final QuerySnapshot _matchSnapshot = await _db
        .collection("matchData")
        .where("matchUID", isEqualTo: currentUserUID)
        .get();
    final _docs = _matchSnapshot.docs;
    for (var doc in _docs) {
      final Map _matchData = doc.data() as Map;
      final String _likeUID = _matchData["likeUID"];
      final DocumentSnapshot _likeUserData =
          await _db.collection("userData").doc(_likeUID).get();
      final Map _userData = _likeUserData.data() as Map;
      if (_matchData["match"] == true) {
        result.add(MatchCardData(
            name: _userData["name"],
            venue: _matchData["venue"],
            dateType: _matchData["dateType"],
            dateTime: _matchData["dateTime"],
            image: _userData["imageURLs"][0]));
      }
      result.add(MatchCardData(
          name: _userData["name"],
          image: _userData["imageURLs"][0],
          dateTypes: _userData["dates"]));
    } return result;
  }

  Future<List<MatchCardData>> get newDatesData async {
    List<MatchCardData> result = [];
    final QuerySnapshot _matchSnapshot = await _db
        .collection("matchData")
        .where("likeUID", isEqualTo: currentUserUID)
        .where("match", isEqualTo: true)
        .get();
    final _docs = _matchSnapshot.docs;
    for (var doc in _docs) {
      final Map _matchData = doc.data() as Map;
      final String _likeUID = _matchData["likeUID"];
      final DocumentSnapshot _likeUserData =
          await _db.collection("userData").doc(_likeUID).get();
      final Map _userData = _likeUserData.data() as Map;
      if (_matchData["match"] == true) {
        result.add(MatchCardData(
            name: _userData["name"],
            venue: _matchData["venue"],
            dateType: _matchData["dateType"],
            dateTime: _matchData["dateTime"],
            image: _userData["imageURLs"][0]));
      }
      result.add(MatchCardData(
          name: _userData["name"],
          image: _userData["imageURLs"][0],
          dateTypes: _userData["dates"]));
    }
    return result;
  }

  Stream<MatchCardData> get newMatchDataStream async* {
    final List<MatchCardData> result = await newMatchData + await newDatesData;
    yield* Stream.fromIterable(result);
  }

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
  MatchCardData(
      {required this.name,
      this.image,
      this.dateTime,
      this.venue,
      this.dateType,
      this.dateTypes});
  final String name;
  final String? image;
  final String? venue;
  final DateTime? dateTime;
  final String? dateType;
  final List? dateTypes;

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
