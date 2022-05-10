import 'package:cloud_firestore/cloud_firestore.dart';
import "package:async/async.dart";
import '../models/users.dart';

class MatchDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> get _likesStream async* {
    // this grabs dates with people you liked
    yield* _db
        .collection("matchData")
        .where("likeUID", isEqualTo: UserData.userUID)
        .where("match", isEqualTo: true)
        .get()
        .asStream();
  }

  Stream<QuerySnapshot> get _pendingStream async* {
    // this grabs people who have liked you but you haven't said yes to
    yield* _db
        .collection("matchData")
        .where("matchUID", isEqualTo: UserData.userUID)
        .where("match", isEqualTo: false)
        .get()
        .asStream();
  }

  Stream<QuerySnapshot> get _matchStream async* {
    yield* _db
        .collection("matchData")
        .where("matchUID", isEqualTo: UserData.userUID)
        .where("match", isEqualTo: true)
        .get()
        .asStream();
  }

  Stream<QuerySnapshot> get matchDataStream async* {
    yield* StreamGroup.merge([_likesStream, _pendingStream, _matchStream]);
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
    final String uid = data["likeUID"] == UserData.userUID
        ? data["matchUID"]
        : data["likeUID"];
    final _data = await db.collection("userData").doc(uid).get();
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