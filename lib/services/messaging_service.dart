import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rendezvous_beta_v3/services/authentication_service.dart';

class MessengingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  Stream<QuerySnapshot> unreadMessages(String targetUID) async* {
    yield* _db
        .collection("userData")
        .doc(AuthenticationService.currentUserUID)
        .collection("matches")
        .doc(targetUID)
        .collection("messages")
        .where("sender", isEqualTo: targetUID)
        .where("read", isEqualTo: false)
        .get().asStream();
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
      "target" : targetUID,
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
      "target" : targetUID,
      "read": false,
      "timeStamp": DateTime.now()
    });
  }

  void markMessagesRead(String targetUID) async {
    final QuerySnapshot _yourMessages = await _db
        .collection("userData")
        .doc(AuthenticationService.currentUserUID)
        .collection("matches")
        .doc(targetUID)
        .collection("messages")
        .get();
    final QuerySnapshot _theirMessages = await _db
        .collection("userData")
        .doc(targetUID)
        .collection("matches")
        .doc(AuthenticationService.currentUserUID)
        .collection("messages")
        .get();
    _yourMessages.docs.forEach((doc) {
      if (doc.exists && doc.data() != null) {
        final Map _data = doc.data() as Map;
        if (_data["sender"] != AuthenticationService.currentUserUID) {
          doc.reference.update({"read": true});
        }
      }
    });
    _theirMessages.docs.forEach((doc) {
      if (doc.exists && doc.data() != null) {
        final Map _data = doc.data() as Map;
        if (_data["sender"] != targetUID) {
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
