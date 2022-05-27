import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rendezvous_beta_v3/services/authentication.dart';

class MatchDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DateTime _convertTimeStamp(dynamic dateValue) {
    if (dateValue is DateTime) {
      return dateValue;
    } else if (dateValue is String) {
      return DateTime.parse(dateValue);
    } else if (dateValue is Timestamp) {
      return dateValue.toDate();
    } else {
      throw("Invalid dateTime value returned from firestore");
    }
  }


  Future<List<MatchCardData>> get matchData async {
    List<MatchCardData> result = [];
    final QuerySnapshot _matchSnapshot = await _db
        .collection("matchData")
        .where("matchUID", isEqualTo: currentUserUID)
        .get();
    final _docs = _matchSnapshot.docs;
    try {
      for (var doc in _docs) {
        final Map _matchData = doc.data() as Map;
        final String _likeUID = _matchData["likeUID"];
        final DocumentSnapshot _likeUserData =
        await _db.collection("userData").doc(_likeUID).get();
        final Map _userData = _likeUserData.data() as Map;
        if (_matchData["match"] == true) {
          result.add(MatchCardData(
              name: _userData["name"],
              matchID: _likeUID,
              venue: _matchData["venue"],
              dateType: _matchData["dateType"],
              dateTime: _convertTimeStamp(_matchData["dateTime"]),
              image: _userData["imageURLs"][0]));
        } else {
          result.add(MatchCardData(
              name: _userData["name"],
              matchID: _likeUID,
              image: _userData["imageURLs"][0],
              dateTypes: _userData["dates"]));
        }
      }
    } catch (e) {
      print(e);
    }
    return result;
  }

  Future<List<MatchCardData>> get datesData async {
    List<MatchCardData> result = [];
    final QuerySnapshot _matchSnapshot = await _db
        .collection("matchData")
        .where("likeUID", isEqualTo: currentUserUID)
        .where("match", isEqualTo: true)
        .get();
    final _docs = _matchSnapshot.docs;
    try {
      for (var doc in _docs) {
        final Map _matchData = doc.data() as Map;
        final String _matchUID = _matchData["matchUID"];
        final DocumentSnapshot _likeUserData =
        await _db.collection("userData").doc(_matchUID).get();
        final Map _userData = _likeUserData.data() as Map;
        if (_matchData["match"] == true) {
          result.add(MatchCardData(
              name: _userData["name"],
              matchID: _matchUID,
              venue: _matchData["venue"],
              dateType: _matchData["dateType"],
              dateTime: _convertTimeStamp(_matchData["dateTime"]),
              image: _userData["imageURLs"][0]));
        } else {
          result.add(MatchCardData(
              name: _userData["name"],
              matchID: _matchUID,
              image: _userData["imageURLs"][0],
              dateTypes: _userData["dates"]));
        }
      }
    } catch (e) {
      print(e);
    } return result;
  }

  Stream<List<MatchCardData>> get matchDataStream async* {
    final List<MatchCardData> result = await matchData + await datesData;
    yield* Stream.value(result);
  }

  static Future<void> setMatchData({required String currentDiscoverUID}) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      await db.collection("matchData").doc(currentUserUID! + currentDiscoverUID).set({
        "likeUID": currentUserUID,
        "matchUID": currentDiscoverUID,
        "match": false
      });
    } catch (e) {
      print(e);
    }
  }

  static Future<void> updateMatchData(
      // TODO: delete matchData where path is not of form below
      {required otherUserUID,
      required String dateType,
      required DateTime dateTime,
      required String venue}) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      await db.collection("matchData").doc(currentUserUID! + otherUserUID).update({
        "venue": venue,
        "match": true,
        "dateType": dateType,
        "dateTime": dateTime
      });
    } catch (e) {
      print(e);
    }
  }
}

class MatchCardData {
  MatchCardData(
      {required this.name,
        required this.matchID,
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
  final String matchID;
}
