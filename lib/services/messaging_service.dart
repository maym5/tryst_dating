import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rendezvous_beta_v3/services/authentication.dart';

class MessengingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// we want this class to return a list of messages


  Future<bool> hasUnreadMessages(String targetUID) async {
    final QuerySnapshot unreadMessages = await _db
        .collection("userData")
        .doc(currentUserUID)
        .collection("matches")
        .doc(targetUID)
        .collection("messages").where("read", isEqualTo: false).get();
    return unreadMessages.size != 0;
  }

  void sendMessage(String message, String targetUID) async {
    await _db
        .collection("userData")
        .doc(currentUserUID)
        .collection("matches")
        .doc(targetUID)
        .collection("messages")
        .add({"message": message, "sender": currentUserUID, "read" : false});
    // ref.update({"docRef" : ref.id});
  }

  void markMessagesRead(String targetUID) async {
    // TODO: possible improvements from StackOverflow
    final QuerySnapshot _querySnapshot = await _db.collection("userData")
        .doc(currentUserUID)
        .collection("matches")
        .doc(targetUID)
        .collection("messages").get();
    _querySnapshot.docs.forEach((doc) {
      if (doc.exists && doc.data() != null) {
        doc.reference.update({"read" : true});
      }
    });
    // final List<DocumentSnapshot> docs = _querySnapshot.docs;
    // for (DocumentSnapshot doc in docs) {
    //   if (doc.exists && doc.data() != null) {
    //     final Map<String, dynamic> _data = doc.data() as Map<String, dynamic>;
    //     if (_data["read"] == false) {
    //       _db.collection("userData")
    //           .doc(currentUserUID)
    //           .collection("matches")
    //           .doc(targetUID)
    //           .collection("messages").doc(_data["docRef"]).update({"read" : true});
    //     }
    //   }
    // }
  }

  Stream<List<MessengerData>> messageStream(String targetUID) async* {
    final List<MessengerData> result = [];
    final Stream<QuerySnapshot> snapshot = _db
        .collection("userData")
        .doc(currentUserUID)
        .collection("matches")
        .doc(targetUID)
        .collection("messages")
        .snapshots();
    await for (QuerySnapshot query in snapshot) {
      if (query.size != 0) {
        final List<DocumentSnapshot> docs = query.docs;
        for (DocumentSnapshot doc in docs) {
          if (doc.exists && doc.data() != null) {
            final Map<String, dynamic> _data = doc.data() as Map<String, dynamic>;
            if (_data["message"] != null && _data["sender"] != null) {
              result.add(MessengerData(
                  message: _data["message"]!, sender: _data["sender"]!));
              yield result;
            }
          }
        }
      }
    }
  }
}

class MessengerData {
  MessengerData({required this.message, required this.sender});
  final String message;
  final String sender;
}
