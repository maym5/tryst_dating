import 'package:firebase_auth/firebase_auth.dart';


Future onEmailAndPasswordLogin(String email, String password) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  try {
    UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email, password: password);
    return Future.value(userCredential.user);
  } on FirebaseAuthException catch (e) {
    return Future.value(e.code);
  }
}

Future onEmailAndPasswordSignUp(String email, String password) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  try {
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return Future.value(userCredential.user);
  } on FirebaseAuthException catch (e) {
    return Future.value(e.code);
  }
}

String? get currentUserUID {
  FirebaseAuth auth = FirebaseAuth.instance;
  return auth.currentUser?.uid;
}

Future verifyEmail() {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null && !user.emailVerified) {
    return user.sendEmailVerification();
  } else {
    return Future.error('invalid user');
  }
}

// Future<void> getUserData() async {
//   FirebaseFirestore _db = FirebaseFirestore.instance;
//   User? user = FirebaseAuth.instance.currentUser;
//   final DocumentSnapshot<Map<String, dynamic>> _rawData =
//       await _db.collection("userData").doc(user?.uid).get();
//   final Map<String, dynamic> _data = _rawData.data()!;
//   UserData.fromJson(_data);
//   UserImages.getImagesFromUserData();
// }

Future<void> logOut() async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  await auth.signOut();
}