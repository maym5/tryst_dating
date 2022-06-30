import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rendezvous_beta_v3/services/authentication.dart';
import 'dart:async';

import '../models/users.dart';

class MatchDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static DateTime convertTimeStamp(dynamic dateValue) {
    if (dateValue is DateTime) {
      return dateValue;
    } else if (dateValue is String) {
      return DateTime.parse(dateValue);
    } else if (dateValue is Timestamp) {
      return dateValue.toDate();
    } else {
      throw ("Invalid dateTime value returned from firestore");
    }
  }

  Stream<List<MatchData>?> get likesStream async* {
    Stream<QuerySnapshot> _data = _db
        .collection("userData")
        .doc(currentUserUID)
        .collection("matches")
        .where("match", isEqualTo: false)
        .snapshots();
    final List<MatchData> result = <MatchData>[];
    await for (QuerySnapshot snapshot in _data) {
      if (snapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          if (doc.exists && doc.data() != null) {
            Map<String, dynamic> _matchData =
                doc.data() as Map<String, dynamic>;
            final String _matchUID = _matchData["matchUID"];
            final DocumentSnapshot _matchUserData =
                await _db.collection("userData").doc(_matchUID).get();
            if (_matchUserData.exists && _matchUserData.data() != null) {
              final Map _userData = _matchUserData.data() as Map;
              result.add(MatchData(
                  name: _userData["name"],
                  age: _userData["age"],
                  matchID: _matchUID,
                  image: _userData["imageURLs"][0],
                  dateTypes: _userData["dates"]));
              yield result;
            }
          }
        }
      }
    }
  }

  Stream<List<MatchData>?> get datesStream async* {
    Stream<QuerySnapshot> _data = _db
        .collection("userData")
        .doc(currentUserUID)
        .collection("matches")
        .where("match", isEqualTo: true)
        .snapshots();
    final List<MatchData> result = <MatchData>[];
    await for (QuerySnapshot snapshot in _data) {
      if (snapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          if (doc.exists && doc.data() != null) {
            final Map _matchData = doc.data() as Map;
            final String _matchUID = _matchData["matchUID"];
            final DocumentSnapshot _matchUserData =
                await _db.collection("userData").doc(_matchUID).get();
            if (_matchUserData.exists && _matchUserData.data() != null) {
              final Map _userData = _matchUserData.data() as Map;
              result.add(MatchData(
                  name: _userData["name"],
                  matchID: _matchUID,
                  venue: _matchData["venue"],
                  dateType: _matchData["dateType"],
                  dateTime: convertTimeStamp(_matchData["dateTime"]),
                  image: _userData["imageURLs"][0]));
              yield result;
            }
          }
        }
      }
    }
  }

  Stream<QuerySnapshot> get newLikeStream async* {
    yield* _db
        .collection("userData")
        .doc(currentUserUID)
        .collection("matches")
        .where("match", isEqualTo: false)
        .snapshots();
  }

  Stream<QuerySnapshot> get newDateData async* {
    yield* _db
        .collection("userData")
        .doc(currentUserUID)
        .collection("matches")
        .where("match", isEqualTo: true)
        .snapshots();
  }

  static Future<void> setMatchData(
      {required String currentDiscoverUID,
      required double userRating,
      required String name,
        required int age,
      required String image}) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      await db
          .collection("userData")
          .doc(currentUserUID)
          .collection("matches")
          .doc(currentDiscoverUID)
          .set({
        "matchUID": currentDiscoverUID,
        "match": false,
        "userRating": userRating,
        "name": name,
        "avatarImage": image,
        "age" : age
      });
      await db
          .collection("userData")
          .doc(currentDiscoverUID)
          .collection("matches")
          .doc(currentUserUID)
          .set({
        "matchUID": currentUserUID,
        "match": false,
        "otherUserRating": userRating,
        "name": UserData.name,
        "avatarImage": UserData.imageURLs,
        "age" : UserData.age
      });
    } catch (e) {
      print(e);
    }
  }

  static Future<void> updateMatchData({
    required otherUserUID,
    required String dateType,
    required DateTime dateTime,
    required String venue,
    double? userRating,
  }) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      await db
          .collection("userData")
          .doc(currentUserUID)
          .collection("matches")
          .doc(otherUserUID)
          .update({
        "venue": venue,
        "match": true,
        "dateType": dateType,
        "dateTime": dateTime,
        // TODO: figure this out its super dumb
        "userRating": userRating
      });
      await db
          .collection("userData")
          .doc(otherUserUID)
          .collection("matches")
          .doc(currentUserUID)
          .update({
        "venue": venue,
        "match": true,
        "dateType": dateType,
        "dateTime": dateTime,
        "otherUserRating": userRating
      });
    } catch (e) {
      print(e);
    }
  }
}

class MatchData {
  MatchData(
      {required this.name,
      required this.matchID,
      this.image,
      this.dateTime,
      this.age,
      this.venue,
      this.dateType,
      this.dateTypes});
  final String name;
  final int? age;
  final String? image;
  final String? venue;
  final DateTime? dateTime;
  final String? dateType;
  final List? dateTypes;
  final String matchID;
}
