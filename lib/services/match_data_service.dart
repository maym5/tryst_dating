import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rendezvous_beta_v3/services/authentication.dart';

class MatchDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;


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

  Stream<List<MatchCardData>> get newMatchDataStream async* {
    final List<MatchCardData> result = await newMatchData + await newDatesData;
    yield* Stream.value(result);
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
}
