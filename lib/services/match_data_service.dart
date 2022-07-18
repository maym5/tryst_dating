import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rendezvous_beta_v3/services/authentication_service.dart';
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

  Stream<QuerySnapshot> get likeStream async* {
    yield* _db
        .collection("userData")
        .doc(AuthenticationService.currentUserUID)
        .collection("matches")
        .where("match", isEqualTo: false)
        .snapshots();
  }

  Stream<QuerySnapshot> get dateData async* {
    yield* _db
        .collection("userData")
        .doc(AuthenticationService.currentUserUID)
        .collection("matches")
        .where("match", isEqualTo: true)
        .snapshots();
  }

  static Future<void> setMatchData(
      {required String currentDiscoverUID,
      required double userRating,
      required String name,
      required int age,
      required List<String> dateTypes,
      required String image}) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      await db
          .collection("userData")
          .doc(AuthenticationService.currentUserUID)
          .collection("matches")
          .doc(currentDiscoverUID)
          .set({
        "matchUID": currentDiscoverUID,
        "match": false,
        "userRating": userRating,
        "name": name,
        "avatarImage": image,
        "age": age,
        "dateTypes": dateTypes,
        "seen": true,
      });
      await db
          .collection("userData")
          .doc(currentDiscoverUID)
          .collection("matches")
          .doc(AuthenticationService.currentUserUID)
          .set({
        "matchUID": AuthenticationService.currentUserUID,
        "match": false,
        "otherUserRating": userRating,
        "name": UserData.name,
        "avatarImage": UserData.imageURLs[0],
        "age": UserData.age,
        "dateTypes": UserData.dates.toList(),
        "seen": false
      });
    } catch (e) {
      print(e);
    }
  }

  static Future<bool> updateMatchData({
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
          .doc(AuthenticationService.currentUserUID)
          .collection("matches")
          .doc(otherUserUID)
          .update({
        "venue": venue,
        "match": true,
        "dateType": dateType,
        "dateTime": dateTime,
        "userRating": userRating,
        "seen": true,
        "agreedToDate": [AuthenticationService.currentUserUID]
      });
      await db
          .collection("userData")
          .doc(otherUserUID)
          .collection("matches")
          .doc(AuthenticationService.currentUserUID)
          .update({
        "venue": venue,
        "match": true,
        "dateType": dateType,
        "dateTime": dateTime,
        "otherUserRating": userRating,
        "seen": true,
        "agreedToDate": [AuthenticationService.currentUserUID]
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<void> confirmDate({required String otherUserUID}) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      await db
          .collection("userData")
          .doc(AuthenticationService.currentUserUID)
          .collection("matches")
          .doc(otherUserUID)
          .update({
        "agreedToDate": [AuthenticationService.currentUserUID, otherUserUID]
      });
      await db
          .collection("userData")
          .doc(otherUserUID)
          .collection("matches")
          .doc(AuthenticationService.currentUserUID)
          .update({
        "agreedToDate": [AuthenticationService.currentUserUID, otherUserUID]
      });
    } catch (e) {}
  }

  static Future<bool> deleteDate({required String otherUserUID}) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      await db
          .collection("userData")
          .doc(AuthenticationService.currentUserUID)
          .collection("matches")
          .doc(otherUserUID)
          .delete();
      await db
          .collection("userData")
          .doc(otherUserUID)
          .collection("matches")
          .doc(AuthenticationService.currentUserUID)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  /* static Future<void> moveToOldDates({required otherUserUID}) {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      final _yourOldDateData = db
          .collection("userData")
          .doc(AuthenticationService.currentUserUID)
          .collection("matches")
          .doc(otherUserUID)
          .get() as Map;
      db.collection("userData").doc(AuthenticationService.currentUserUID).collection("pastDates").doc(otherUserUID).set({
        "name" : _yourOldDateData["name"],
      });
    } catch (e) {}
  }*/
}

class DateData {
  DateData(
      {required this.name,
      required this.matchID,
      this.image,
      this.dateTime,
      this.age,
      this.venue,
      this.dateType,
      this.dateTypes,
      this.agreedToDate});
  final String name;
  final int? age;
  final String? image;
  final String? venue;
  final DateTime? dateTime;
  final String? dateType;
  final List? dateTypes;
  final String matchID;
  final List? agreedToDate;
}
