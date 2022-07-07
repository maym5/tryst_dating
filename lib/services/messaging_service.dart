import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rendezvous_beta_v3/services/authentication_service.dart';

class MessengingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// we want this class to return a list of messages

  Future<bool> hasUnreadMessages(String targetUID) async {
    final QuerySnapshot unreadMessages = await _db
        .collection("userData")
        .doc(AuthenticationService.currentUserUID)
        .collection("matches")
        .doc(targetUID)
        .collection("messages")
        .where("sender", isEqualTo: targetUID)
        .where("read", isEqualTo: false)
        .get();
    return unreadMessages.size != 0;
  }

  void sendMessage(String message, String targetUID) async {
    await _db
        .collection("userData")
        .doc(AuthenticationService.currentUserUID)
        .collection("matches")
        .doc(targetUID)
        .collection("messages")
        .add({
      "message": message,
      "sender": AuthenticationService.currentUserUID,
      "read": false,
      "timeStamp": DateTime.now()
    });
    await _db
        .collection("userData")
        .doc(targetUID)
        .collection("matches")
        .doc(AuthenticationService.currentUserUID)
        .collection("messages")
        .add({
      "message": message,
      "sender": AuthenticationService.currentUserUID,
      "read": false,
      "timeStamp": DateTime.now()
    });
  }

  void markMessagesRead(String targetUID) async {
    // TODO: get it to work
    final QuerySnapshot _querySnapshot = await _db
        .collection("userData")
        .doc(AuthenticationService.currentUserUID)
        .collection("matches")
        .doc(targetUID)
        .collection("messages")
        .get();
    _querySnapshot.docs.forEach((doc) {
      if (doc.exists && doc.data() != null) {
        final Map _data = doc.data() as Map;
        if (_data["sender"] != AuthenticationService.currentUserUID) {
          doc.reference.update({"read": true});
        }
      }
    });
  }

  Stream<QuerySnapshot> messageStream(String targetUID) async* {
    yield* _db
        .collection("userData")
        .doc(AuthenticationService.currentUserUID)
        .collection("matches")
        .doc(targetUID)
        .collection("messages")
        .orderBy("timeStamp")
        .snapshots();
  }
}

class MessengerData {
  MessengerData({required this.message, required this.sender});
  final String message;
  final String sender;
}
